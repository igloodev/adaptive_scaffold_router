## 0.3.1

Documentation and screenshots, no code changes.

* Add a **How it works** table to the README mapping each breakpoint to its
  navigation, including the `permanentDrawer` override.
* Regenerate the desktop screenshot with `permanentDrawer: true` so the v0.3.0
  drawer is now shown (phone and tablet screenshots refreshed for consistency),
  and update the screenshot caption and `pubspec` description to match.

## 0.3.0

Completes the Material 3 adaptive navigation progression, backward-compatible
(no breaking changes).

* **Permanent navigation drawer on desktop.** New `permanentDrawer` flag on
  `AdaptiveScaffold` (and `AdaptiveNavigationShell`) renders a persistent
  `NavigationDrawer` as the primary navigation at the large and extra-large
  breakpoints, instead of the extended rail — the widest tier of the Material 3
  progression (`bottom bar → rail → drawer`). The medium and medium-large
  breakpoints keep the rail.
* **`AdaptiveScaffold.standardDrawer` helper.** Builds a width-bounded
  `NavigationDrawer` from a list of `NavigationDestination`s, with optional
  `leading`/`trailing` header and footer slots (neither affects the selected
  index).
* Branch state is still preserved across every breakpoint — resizing between the
  rail and the drawer never rebuilds the body.
* Example now enables `permanentDrawer: true`. New tests for the drawer helper,
  the breakpoint switch, the shell pass-through and state preservation (24 tests
  total).

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
