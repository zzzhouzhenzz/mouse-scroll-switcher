import AppKit

private func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else {
        fputs("FAIL: \(message)\n", stderr)
        exit(EXIT_FAILURE)
    }
}

@main
private enum Tests {
    static func main() {
        check(!shouldNotify(naturalScrolling: false, hasNonAppleMouse: true),
              "mouse with Natural scrolling off stays quiet")
        check(shouldNotify(naturalScrolling: true, hasNonAppleMouse: true),
              "mouse with Natural scrolling on notifies")
        check(!shouldNotify(naturalScrolling: true, hasNonAppleMouse: false),
              "no mouse with Natural scrolling on stays quiet")
        check(shouldNotify(naturalScrolling: false, hasNonAppleMouse: false),
              "no mouse with Natural scrolling off notifies")

        // Exercise the real event observers and one-shot timer in this process.
        // No settings are changed and the notification callback displays nothing.
        NSApplication.shared.setActivationPolicy(.accessory)
        var checks = 0
        guard let checkNow = startMouseStatusChecks(
            notification: { _ in }, onCheck: { _ in checks += 1 }
        ) else {
            fputs("FAIL: could not open HID manager for event integration tests\n", stderr)
            exit(EXIT_FAILURE)
        }
        RunLoop.main.run(until: Date().addingTimeInterval(1.4))
        check(checks == 1, "launch and initial device enumeration settle into one check")

        let workspace = NSWorkspace.shared.notificationCenter
        let events: [(NotificationCenter, Notification.Name)] = [
            (workspace, NSWorkspace.didWakeNotification),
            (workspace, NSWorkspace.screensDidWakeNotification),
            (workspace, NSWorkspace.sessionDidBecomeActiveNotification),
            (.default, NSApplication.didChangeScreenParametersNotification),
        ]
        for (center, event) in events {
            let before = checks
            center.post(name: event, object: nil)
            check(checks == before, "\(event) waits for devices to settle")
            RunLoop.main.run(until: Date().addingTimeInterval(1.2))
            check(checks == before + 1, "\(event) triggers a fresh check")
        }

        let beforeBurst = checks
        for (center, event) in events { center.post(name: event, object: nil) }
        RunLoop.main.run(until: Date().addingTimeInterval(0.65))
        check(checks == beforeBurst, "a wake/display burst does not check immediately")
        workspace.post(name: NSWorkspace.didWakeNotification, object: nil)
        RunLoop.main.run(until: Date().addingTimeInterval(0.65))
        check(checks == beforeBurst, "a later event restarts the settling delay")
        RunLoop.main.run(until: Date().addingTimeInterval(0.6))
        check(checks == beforeBurst + 1, "a settled burst checks exactly once")

        let beforeManual = checks
        workspace.post(name: NSWorkspace.screensDidWakeNotification, object: nil)
        checkNow()
        check(checks == beforeManual + 1, "Check Now checks immediately")
        RunLoop.main.run(until: Date().addingTimeInterval(1.2))
        check(checks == beforeManual + 1, "Check Now cancels the pending check; no polling")
        print("PASS")
    }
}
