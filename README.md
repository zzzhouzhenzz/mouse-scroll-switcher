<p align="center">
  <img src="assets/app-icon.png" width="144" alt="Mouse Scroll Switcher icon">
</p>

<h1 align="center">Mouse Scroll Switcher</h1>

<p align="center">
  A tiny macOS reminder that keeps Natural scrolling sensible when you switch between a trackpad and a non-Apple mouse.
</p>

![How Mouse Scroll Switcher works](assets/overview.svg)

## What it does

Mouse Scroll Switcher checks the current devices and Natural scrolling preference when it launches and whenever a mouse connects or disconnects.

| Current devices | Expected setting | Result when matched |
| --- | --- | --- |
| A non-Apple mouse is connected | Natural scrolling off | Quiet |
| No non-Apple mouse is connected | Natural scrolling on | Quiet |

When they do not match, a persistent notification offers two choices: **Open Trackpad Settings** or **Not Now**. The first opens Trackpad → Scroll & Zoom directly.

It does not intercept scrolling, install an event tap, require Accessibility permission, poll in the background, or silently modify a system setting.

## Install

Download `MouseScrollSwitcher-v1.0.0.zip` from the latest release, unzip it, and move the app to Applications. Because v1 is ad-hoc signed rather than notarized, macOS may require **Control-click → Open** on first launch.

Allow notifications when prompted. For notifications that remain visible until acted on, macOS should use **Alerts** for Mouse Scroll Switcher in System Settings → Notifications.

Add the app to System Settings → General → Login Items if you want it to run after login.

## Build from source

Requires macOS 14 or newer and Xcode Command Line Tools.

```sh
make test
make
open MouseScrollSwitcher.app
```

The project also includes a Swift package manifest for editor indexing.

## How small is it?

The production app has three Swift files:

- `main.swift` wires up the accessory app.
- `Core.swift` listens for public HID connection changes and makes the stateless decision.
- `Notification.swift` presents the notification and opens System Settings.

The HID matching API is public. Reading `com.apple.swipescrolldirection` and opening an `x-apple.systempreferences:` deep link rely on undocumented macOS behavior and may need adjustment on a future release.

## License

MIT
