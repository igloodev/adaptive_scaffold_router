# adaptive_scaffold_router

Adaptive **Material 3** navigation for Flutter that switches
`BottomNavigationBar → NavigationRail → Drawer` by screen size — with
**first-class `go_router` support** and **branch state preserved across
breakpoint changes**.

A drop-in successor to Google's discontinued
[`flutter_adaptive_scaffold`](https://pub.dev/packages/flutter_adaptive_scaffold),
picking up where it left off.

<p align="center">
  <img src="https://raw.githubusercontent.com/igloodev/adaptive_scaffold_router/master/screenshots/demo.gif" alt="Resizing the window morphs the navigation while the body state is preserved" width="640">
</p>

<p align="center"><em>One layout, three forms — and the counter keeps its value across every resize.</em></p>

## Why this package?

Google [discontinued `flutter_adaptive_scaffold`](https://github.com/flutter/flutter/issues/162965)
in April 2025 to focus on core framework work — not because it was unpopular
(it still gets thousands of downloads a week). It invited the community to make
**one sustainable fork** rather than many one-off forks.

The forks that appeared mostly added cosmetic options. They left the two pain
points developers actually hit untouched:

| Pain with the original | `adaptive_scaffold_router` |
| --- | --- |
| No documented way to use it with **`go_router`** ([flutter#129850](https://github.com/flutter/flutter/issues/129850)) | `AdaptiveNavigationShell` — drop-in `StatefulShellRoute` integration |
| **State is lost** when the breakpoint changes (phone ↔ tablet rebuilds the body) | Body is kept mounted; only the navigation chrome changes |
| Material-only | Material 3 today; Cupertino on the roadmap |

Everything else stays **API-compatible**, so migrating is a one-line import
change.

## Features

- 📱 **Adaptive navigation** — bottom bar on phones, rail on tablets, extended
  rail / drawer on desktop, with smooth animated transitions.
- 🧭 **`go_router` in a few lines** — `AdaptiveNavigationShell` connects
  `StatefulShellRoute.indexedStack` to the adaptive layout.
- 🧠 **State preserved across resizes** — scroll position, form input and
  in-memory state survive when the window changes size.
- 🔁 **Drop-in migration** from `flutter_adaptive_scaffold` 0.3.x.
- 🧩 **Low-level building blocks** — `AdaptiveLayout`, `SlotLayout` and
  `Breakpoint`s are all exposed for full customization.
- 🪟 Two-pane (list/detail) `body` + `secondaryBody`, foldable-aware.

## Screenshots

| Phone | Tablet | Desktop |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/igloodev/adaptive_scaffold_router/master/screenshots/01_phone.png" width="220"> | <img src="https://raw.githubusercontent.com/igloodev/adaptive_scaffold_router/master/screenshots/02_tablet.png" width="240"> | <img src="https://raw.githubusercontent.com/igloodev/adaptive_scaffold_router/master/screenshots/03_desktop.png" width="240"> |
| Bottom navigation bar | Navigation rail | Extended navigation rail |

## Install

```yaml
dependencies:
  adaptive_scaffold_router: ^0.1.0
```

## Quick start — with `go_router`

Wrap your `StatefulShellRoute` branches in an `AdaptiveNavigationShell`:

```dart
import 'package:adaptive_scaffold_router/adaptive_scaffold_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/inbox',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) =>
          AdaptiveNavigationShell(
        navigationShell: navigationShell,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(path: '/inbox', builder: (_, __) => const InboxPage()),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(path: '/articles', builder: (_, __) => const ArticlesPage()),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
        ]),
      ],
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: router);
}
```

The number of `destinations` matches the number of `StatefulShellBranch`es.
Resize the window from phone to desktop width and watch the navigation morph —
while each tab keeps exactly where you left it.

## Without `go_router`

`AdaptiveScaffold` works standalone, exactly like the original:

```dart
AdaptiveScaffold(
  selectedIndex: _index,
  onSelectedIndexChange: (int i) => setState(() => _index = i),
  destinations: const <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
    NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
  ],
  body: (_) => MyBody(index: _index),
  // Optional per-breakpoint bodies:
  smallBody: (_) => MyCompactBody(index: _index),
  secondaryBody: (_) => MyDetailPane(),
)
```

## Migrating from `flutter_adaptive_scaffold`

Change the dependency and the import:

```diff
- flutter_adaptive_scaffold: ^0.3.3
+ adaptive_scaffold_router: ^0.1.0
```

```diff
- import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
+ import 'package:adaptive_scaffold_router/adaptive_scaffold_router.dart';
```

`AdaptiveScaffold`, `AdaptiveLayout`, `SlotLayout`, `Breakpoint` and
`Breakpoints` keep the same API. To also fix `go_router` state loss, move your
navigation into an `AdaptiveNavigationShell` (see above).

## How state preservation works

Two things combine:

1. **`go_router`** lays branches out in an `IndexedStack`
   (`StatefulShellRoute.indexedStack`), so each branch's `Navigator` stays
   mounted while you switch tabs.
2. **`adaptive_scaffold_router`** feeds that single `navigationShell` widget into
   the scaffold body under **one stable key for every breakpoint**. Changing
   the breakpoint therefore only swaps the navigation chrome — the body subtree
   is never torn down.

The original assigned a different body slot/key per breakpoint, so resizing
rebuilt the body and dropped its state. This package doesn't.

## Breakpoints

Material 3 breakpoints are provided out of the box and can be overridden:

| Breakpoint | Width (dp) | Typical chrome |
| --- | --- | --- |
| `small` | 0–600 | Bottom navigation bar |
| `medium` | 600–840 | Navigation rail |
| `mediumLarge` | 840–1200 | Extended rail |
| `large` | 1200–1600 | Extended rail |
| `extraLarge` | 1600+ | Extended rail |

```dart
AdaptiveNavigationShell(
  navigationShell: navigationShell,
  destinations: destinations,
  smallBreakpoint: const Breakpoint.small(),
  mediumBreakpoint: Breakpoints.medium,
  // ...custom Breakpoints supported
)
```

## Roadmap

- Cupertino / platform-adaptive navigation.
- Richer per-destination customization (label visibility, icon transitions).

## Credits

Derived from `flutter_adaptive_scaffold` by The Flutter Authors, used under its
BSD 3-Clause license. See [LICENSE](LICENSE).
