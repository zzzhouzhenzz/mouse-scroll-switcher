import AppKit
import IOKit.hid

private let appleVendorID = 0x05ac
private let scrollingKey = "com.apple.swipescrolldirection"
private var manager: IOHIDManager?
private var notify: ((Bool) -> Void)?
private var checked: ((Bool?) -> Void)?
private var pendingCheck: Timer?
private var observers: [NSObjectProtocol] = []

// Returns the immediate check used by the menu; automatic events share a
// one-shot settling timer. No device snapshots or decision history are stored.
func startMouseStatusChecks(
    notification: @escaping (Bool) -> Void,
    onCheck: @escaping (Bool?) -> Void = { _ in }
) -> (() -> Void)? {
    notify = notification
    checked = onCheck
    // We need discovery and properties only. Do not open input streams on the
    // devices themselves, which can require Input Monitoring permission.
    let hidManager = IOHIDManagerCreate(
        kCFAllocatorDefault, IOHIDManagerOptions.independentDevices.rawValue)
    manager = hidManager
    IOHIDManagerSetDeviceMatching(hidManager, [
        kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
        kIOHIDDeviceUsageKey: kHIDUsage_GD_Mouse,
    ] as CFDictionary)
    IOHIDManagerRegisterDeviceMatchingCallback(hidManager, mouseChanged, nil)
    IOHIDManagerRegisterDeviceRemovalCallback(hidManager, mouseChanged, nil)

    let result = IOHIDManagerOpen(hidManager, IOOptionBits(0))
    guard result == kIOReturnSuccess else {
        NSLog("Could not open the HID manager: 0x%08x", UInt32(bitPattern: result))
        return nil
    }

    IOHIDManagerScheduleWithRunLoop(
        hidManager, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)

    // Workspace notifications must use the workspace's own notification center.
    for name in [NSWorkspace.didWakeNotification,
                 NSWorkspace.screensDidWakeNotification,
                 NSWorkspace.sessionDidBecomeActiveNotification] {
        observers.append(NSWorkspace.shared.notificationCenter.addObserver(
            forName: name, object: nil, queue: .main
        ) { _ in scheduleScrollingStatusCheck() })
    }
    observers.append(NotificationCenter.default.addObserver(
        forName: NSApplication.didChangeScreenParametersNotification,
        object: nil, queue: .main
    ) { _ in scheduleScrollingStatusCheck() })

    // Initial HID enumeration and launch share the same settling check.
    scheduleScrollingStatusCheck()
    return checkScrollingStatus
}

private let mouseChanged: IOHIDDeviceCallback = { _, result, _, _ in
    if result == kIOReturnSuccess { scheduleScrollingStatusCheck() }
}

private func scheduleScrollingStatusCheck() {
    pendingCheck?.invalidate()
    let timer = Timer(timeInterval: 1, repeats: false) { _ in
        checkScrollingStatus()
    }
    pendingCheck = timer
    // Continue checking while the status menu is being tracked.
    RunLoop.main.add(timer, forMode: .common)
}

private func checkScrollingStatus() {
    pendingCheck?.invalidate()
    pendingCheck = nil
    guard let manager,
          let notify,
          let naturalScrolling = UserDefaults.standard.object(
            forKey: scrollingKey) as? Bool else {
        checked?(nil)
        return
    }

    let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice> ?? []
    // The manager contains only Generic Desktop Mouse devices, so this vendor
    // check cannot mistake other kinds of non-Apple HID devices for mice.
    let hasNonAppleMouse = devices.contains { device in
        guard let vendor = IOHIDDeviceGetProperty(
            device, kIOHIDVendorIDKey as CFString) as? NSNumber else { return false }
        return vendor.intValue != appleVendorID
    }

    let mismatch = shouldNotify(
        naturalScrolling: naturalScrolling,
        hasNonAppleMouse: hasNonAppleMouse)
    checked?(!mismatch)
    if mismatch { notify(hasNonAppleMouse) }
}

func shouldNotify(naturalScrolling: Bool, hasNonAppleMouse: Bool) -> Bool {
    naturalScrolling != !hasNonAppleMouse
}
