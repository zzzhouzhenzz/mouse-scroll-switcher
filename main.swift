import AppKit

let notifications = NotificationService()
let app = NSApplication.shared

app.setActivationPolicy(.accessory)
let menuBar = MenuBar(openSettings: notifications.openSettings)
notifications.requestPermission {
    menuBar.check = startMouseStatusChecks(
        notification: notifications.show, onCheck: menuBar.didCheck)
    if menuBar.check == nil { app.terminate(nil) }
}
app.run()
