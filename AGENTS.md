# Agent guide

Mouse Scroll Switcher is deliberately tiny. Preserve that quality.

## Product invariant

On launch, mouse addition/removal, system or screen wake, display changes, and
user-session activation, take a fresh snapshot after one second of quiet.
The menu's **Check Now** action takes the same snapshot immediately:

- If any connected Generic Desktop Mouse is not made by Apple, Natural scrolling should be off.
- Otherwise, Natural scrolling should be on.
- Notify only when the current setting does not match that rule.

The app never changes the setting itself. The notification offers to open the Trackpad **Scroll & Zoom** settings page, where the user remains in control.

## Source map

- `Core.swift`: the stateless decision path, HID callbacks, and wake/display/session observers. The manager is filtered to Generic Desktop Mouse devices before the vendor check. Independent-device mode keeps discovery separate from input-stream access.
- `Notification.swift`: notification permission, content, actions, and the System Settings deep link.
- `MenuBar.swift`: the running indicator, latest check result/time, and menu actions.
- `main.swift`: application wiring and nothing else.
- `tests.swift`: the complete four-case decision table plus event/coalescing/manual-check integration tests.

## Design constraints

Do not add event taps, scroll-event interception, polling, persistent device state, a private settings setter, SwiftUI, or an Xcode project. Do not retain add/remove history: every trigger reads the preference and the manager's current device set again.

The one-shot settling timer and observer tokens are lifecycle resources, not a
device cache. Keep them on the main run loop, including menu tracking mode.

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
