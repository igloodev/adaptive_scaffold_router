## 0.1.0

Initial release.

A drop-in successor to the discontinued `flutter_adaptive_scaffold`, with the
structural gaps the original left open now solved.

* **Drop-in core.** `AdaptiveScaffold`, `AdaptiveLayout`, `SlotLayout`,
  `Breakpoint` and `Breakpoints` are API-compatible with
  `flutter_adaptive_scaffold` 0.3.x — migrate by changing the import.
* **First-class `go_router` integration.** New `AdaptiveNavigationShell` wires
  `StatefulShellRoute.indexedStack` into an adaptive layout in a few lines.
* **State preservation across breakpoints.** Resizing between phone, tablet and
  desktop widths swaps only the navigation chrome (bar ↔ rail ↔ drawer); the
  body subtree — and every branch's scroll position, form input and in-memory
  state — is kept alive.
* Sound null safety, Material 3, supports Flutter 3.22+.
