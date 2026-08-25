import AppKit
import IOKit.hid

private let appleVendorID = 0x05ac
private let scrollingKey = "com.apple.swipescrolldirection"
private var manager: IOHIDManager?
private var notify: ((Bool) -> Void)?

func startMouseStatusChecks(notification: @escaping (Bool) -> Void) {
    notify = notification
    let hidManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(0))
    manager = hidManager
    IOHIDManagerSetDeviceMatching(hidManager, [
        kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
        kIOHIDDeviceUsageKey: kHIDUsage_GD_Mouse,
    ] as CFDictionary)
    IOHIDManagerRegisterDeviceMatchingCallback(hidManager, mouseChanged, nil)
    IOHIDManagerRegisterDeviceRemovalCallback(hidManager, mouseChanged, nil)

    guard IOHIDManagerOpen(hidManager, IOOptionBits(0)) == kIOReturnSuccess else {
        NSApp.terminate(nil)
        return
    }

    checkScrollingStatus() // First-run check before waiting for device changes.
    IOHIDManagerScheduleWithRunLoop(
        hidManager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
}

private let mouseChanged: IOHIDDeviceCallback = { _, result, _, _ in
    if result == kIOReturnSuccess { checkScrollingStatus() }
}

private func checkScrollingStatus() {
    guard let manager,
          let notify,
          let naturalScrolling = UserDefaults.standard.object(
            forKey: scrollingKey) as? Bool else { return }

    let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice> ?? []
    // The manager contains only Generic Desktop Mouse devices, so this vendor
    // check cannot mistake other kinds of non-Apple HID devices for mice.
    let hasNonAppleMouse = devices.contains { device in
        guard let vendor = IOHIDDeviceGetProperty(
            device, kIOHIDVendorIDKey as CFString) as? NSNumber else { return false }
        return vendor.intValue != appleVendorID
    }

    if shouldNotify(
        naturalScrolling: naturalScrolling,
        hasNonAppleMouse: hasNonAppleMouse) {
        notify(hasNonAppleMouse)
    }
}

func shouldNotify(naturalScrolling: Bool, hasNonAppleMouse: Bool) -> Bool {
    naturalScrolling != !hasNonAppleMouse
}
