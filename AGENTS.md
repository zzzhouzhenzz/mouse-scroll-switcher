# Agent guide

Mouse Scroll Switcher is deliberately tiny. Preserve that quality.

## Product invariant

On launch and whenever a mouse is added or removed, take a fresh snapshot:

- If any connected Generic Desktop Mouse is not made by Apple, Natural scrolling should be off.
- Otherwise, Natural scrolling should be on.
- Notify only when the current setting does not match that rule.

The app never changes the setting itself. The notification offers to open the Trackpad **Scroll & Zoom** settings page, where the user remains in control.

## Source map

- `Core.swift`: the stateless decision path and the public `IOHIDManager` callbacks. The manager is filtered to Generic Desktop Mouse devices before the vendor check.
- `Notification.swift`: notification permission, content, actions, and the System Settings deep link.
- `main.swift`: application wiring and nothing else.
- `tests.swift`: the complete four-case decision table.

## Design constraints

Do not add event taps, scroll-event interception, polling, persistent device state, a private settings setter, SwiftUI, or an Xcode project. Do not retain add/remove history: every trigger reads the preference and the manager's current device set again.

Keep helpers local or private unless tests require a pure function. `shouldNotify` is intentionally the only independently tested rule.

`IOHIDManager` device matching is public API. The `com.apple.swipescrolldirection` preference and `x-apple.systempreferences:` deep link are undocumented implementation details; isolate them as constants and expect future macOS versions to require maintenance.

## Verification

```sh
make clean
make test
make
codesign --verify --deep --strict MouseScrollSwitcher.app
```

For a manual smoke test, create a real mismatch between the attached mouse state and Natural scrolling, then launch the app. Do not commit a special smoke-test code path.
