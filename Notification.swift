import AppKit
import UserNotifications

private let actionID = "open-settings"
private let dismissID = "not-now"
private let categoryID = "mouse-presence"
private let notificationID = "scrolling-mismatch"
private let trackpadSettingsURL = URL(string:
    "x-apple.systempreferences:com.apple.Trackpad-Settings.extension?ScrollAndZoom")!

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()

    override init() {
        super.init()
        center.delegate = self
        center.setNotificationCategories([UNNotificationCategory(
            identifier: categoryID,
            actions: [UNNotificationAction(
                identifier: actionID,
                title: "Open Trackpad Settings",
                options: .foreground),
            UNNotificationAction(
                identifier: dismissID,
                title: "Not Now",
                options: [])],
            intentIdentifiers: [],
            options: [])])
    }

    func requestPermission(then start: @escaping () -> Void) {
        center.requestAuthorization(options: .alert) { granted, _ in
            DispatchQueue.main.async {
                if !granted { NSLog("Notifications are disabled") }
                start()
            }
        }
    }

    func show(mousePresent: Bool) {
        let content = UNMutableNotificationContent()
        content.title = "Scrolling settings need attention"
        content.body = "Open Trackpad settings to turn Natural scrolling \(mousePresent ? "off" : "on")?"
        content.categoryIdentifier = categoryID
        center.add(UNNotificationRequest(
            identifier: notificationID,
            content: content,
            trigger: nil))
    }

    func openSettings() {
        NSWorkspace.shared.open(trackpadSettingsURL)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler done: @escaping () -> Void
    ) {
        if response.actionIdentifier == actionID {
            openSettings()
        }
        done()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler show: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        show(.banner)
    }
}
