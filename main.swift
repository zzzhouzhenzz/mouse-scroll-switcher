import AppKit

let notifications = NotificationService()
let app = NSApplication.shared

app.setActivationPolicy(.accessory)
notifications.requestPermission {
    startMouseStatusChecks(notification: notifications.show)
}
app.run()
