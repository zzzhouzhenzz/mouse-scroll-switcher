<p align="center">
  <img src="assets/app-icon.png" width="144" alt="Amethyst up/down arrows on an iridescent pearl background">
</p>

<h1 align="center">Mouse Scroll Switcher</h1>

<p align="center">
  Tired of opening System Settings, finding Trackpad, clicking Scroll &amp; Zoom, and flipping Natural scrolling every time you switch between mouse and trackpad? Thanks, Apple—nothing says “it just works” like doing it yourself. Install this for a reminder when the setting needs changing and a shortcut straight to the toggle.
</p>

![How Mouse Scroll Switcher works](assets/overview.svg)

## What it does

Mouse Scroll Switcher compares your connected devices with the current Natural scrolling preference. It stays quiet when they match and reminds you when they do not.

| Current devices | Expected setting | Result when matched |
| --- | --- | --- |
| A non-Apple mouse is connected | Natural scrolling off | Quiet |
| No non-Apple mouse is connected | Natural scrolling on | Quiet |

When they do not match, a notification offers two choices: **Open Trackpad Settings** or **Not Now**. The first opens Trackpad → Scroll & Zoom directly. You change the setting yourself; the app never changes it for you.

It does not intercept scrolling, install an event tap, require Accessibility permission, poll in the background, or silently modify a system setting.

## When it checks

- At launch.
- When a mouse connects or disconnects.
- After the Mac or its screen wakes.
- When the display configuration changes, including connecting or disconnecting a monitor.
- When your user session becomes active again.
- Immediately when you choose **Check Now** from the menu bar.

Automatic events arriving close together share one check a second after the last event, allowing devices to settle after waking or undocking. Each check reads the current device list and preference again; there is no polling loop or stored device history.

## How to tell it is running

Look for the **↑↓** icon in the menu bar. Open it to see:

- The latest result: settings match, settings need attention, or the preference could not be read.
- The last check time.
- **Check Now**, **Open Trackpad Settings**, and **Quit Mouse Scroll Switcher**.

The icon indicates that the app is running, not which scrolling direction is selected. This is a menu-bar app, so it does not open a main window or appear in the Dock.

## Install

The [v1.0.0 download](https://github.com/zzzhouzhenzz/mouse-scroll-switcher/releases/tag/v1.0.0) predates the menu-bar status, wake/display checks, and pearl icon shown here. [Build from source](#build-from-source) for the current version described in this README.

To use the published v1.0.0 build, download `MouseScrollSwitcher-v1.0.0.zip`, unzip it, and move the app to Applications. The app is ad-hoc signed rather than notarized, so macOS may require **Control-click → Open** on first launch.

Allow notifications when prompted. For notifications that remain visible until acted on, macOS should use **Alerts** for Mouse Scroll Switcher in System Settings → Notifications.

To run at login, add `/Applications/MouseScrollSwitcher.app` under **System Settings → General → Login Items → Open at Login**. This is a standard macOS login item, not a separate background service.

## Build from source

Requires macOS 14 or newer and Xcode Command Line Tools.

```sh
make test
make
open MouseScrollSwitcher.app
```

The project also includes a Swift package manifest for editor indexing.

Tests cover the decision table and post wake/display/session notifications inside
the test process to verify settling and manual checks. They require a macOS user
session and do not change system preferences or display notifications.

## How small is it?

The production app has four Swift files:

- `main.swift` wires up the accessory app.
- `Core.swift` listens for HID, wake, display, and session events and makes the stateless decision.
- `Notification.swift` presents the notification and opens System Settings.
- `MenuBar.swift` presents the running status, last check, and menu actions.

The HID matching API is public. Reading `com.apple.swipescrolldirection` and opening an `x-apple.systempreferences:` deep link rely on undocumented macOS behavior and may need adjustment on a future release.

## License

MIT
