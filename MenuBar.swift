import AppKit

final class MenuBar: NSObject {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let resultItem = NSMenuItem(title: "Waiting for first check…", action: nil, keyEquivalent: "")
    private let timeItem = NSMenuItem(title: "Last checked: not yet", action: nil, keyEquivalent: "")
    private let checkItem = NSMenuItem(title: "Check Now", action: nil, keyEquivalent: "")
    private let openSettings: () -> Void

    var check: (() -> Void)? {
        didSet { checkItem.isEnabled = check != nil }
    }

    init(openSettings: @escaping () -> Void) {
        self.openSettings = openSettings
        super.init()

        if let image = NSImage(systemSymbolName: "computermouse", accessibilityDescription: "Mouse Scroll Switcher") {
            image.isTemplate = true
            image.size = NSSize(width: 18, height: 18)
            item.button?.image = image
        } else {
            item.button?.title = "↕"
        }
        item.button?.toolTip = "Mouse Scroll Switcher is running"

        let menu = NSMenu()
        menu.autoenablesItems = false
        let runningItem = NSMenuItem(title: "Mouse Scroll Switcher is running", action: nil, keyEquivalent: "")
        for row in [runningItem, resultItem, timeItem] {
            row.isEnabled = false
            menu.addItem(row)
        }
        menu.addItem(.separator())
        checkItem.target = self
        checkItem.action = #selector(checkNow)
        checkItem.isEnabled = false
        menu.addItem(checkItem)
        let settingsItem = NSMenuItem(title: "Open Trackpad Settings", action: #selector(showSettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit Mouse Scroll Switcher", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = NSApplication.shared
        menu.addItem(quitItem)
        item.menu = menu
    }

    func didCheck(matches: Bool?) {
        switch matches {
        case true: resultItem.title = "Natural scrolling matches your devices"
        case false: resultItem.title = "Natural scrolling needs attention"
        case nil: resultItem.title = "Couldn’t read Natural scrolling"
        }
        timeItem.title = "Last checked: " + DateFormatter.localizedString(
            from: Date(), dateStyle: .none, timeStyle: .medium)
        item.button?.toolTip = "Mouse Scroll Switcher is running — " + resultItem.title
    }

    @objc private func checkNow() { check?() }
    @objc private func showSettings() { openSettings() }
}
