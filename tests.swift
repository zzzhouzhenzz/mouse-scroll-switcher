import Foundation

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
        print("PASS")
    }
}
