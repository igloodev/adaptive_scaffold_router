## 0.2.0

Adds navigation customization, all backward-compatible (no breaking changes).

* **Cupertino / platform-adaptive bottom bar.** New `bottomNavigationBuilder` on
  `AdaptiveScaffold` (and `AdaptiveNavigationShell`) swaps the small-breakpoint
  bar — plug in a `CupertinoTabBar` via the new `AdaptiveScaffold.cupertinoTabBar`
  helper, or set `cupertino: true` on the shell.
* **Badges.** Documented and tested: compose a Material `Badge` into a
  destination's icon; it renders in both the bottom bar and the rail.
* **Rail header / footer.** Documented `leadingExtendedNavRail` /
  `leadingUnextendedNavRail` (header) and `trailingNavRail` (footer).
* Example now showcases badges, a rail header/footer, and a platform-adaptive
  bottom bar. New tests for all of the above (15 tests total).

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
