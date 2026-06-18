# adaptive_scaffold_router

Adaptive **Material 3** navigation for Flutter that switches
`BottomNavigationBar → NavigationRail → Drawer` by screen size — with
**first-class `go_router` support** and **branch state preserved across
breakpoint changes**.

A drop-in successor to Google's discontinued
[`flutter_adaptive_scaffold`](https://pub.dev/packages/flutter_adaptive_scaffold),
picking up where it left off.

<p align="center">
  <a href="https://pub.dev/packages/adaptive_scaffold_router"><img src="https://img.shields.io/pub/v/adaptive_scaffold_router?logo=dart&color=0175C2" alt="pub version"></a>
  <a href="https://pub.dev/packages/adaptive_scaffold_router/score"><img src="https://img.shields.io/pub/points/adaptive_scaffold_router?color=2EA44F" alt="pub points"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.22%2B-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://github.com/igloodev/adaptive_scaffold_router/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-BSD--3--Clause-blue" alt="license"></a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/igloodev/adaptive_scaffold_router/master/screenshots/demo.gif" alt="Resizing the window morphs the navigation while the body state is preserved" width="640">
</p>

<p align="center"><em>One layout, three forms — and the counter keeps its value across every resize.</em></p>

## Why this package?

Google [discontinued `flutter_adaptive_scaffold`](https://github.com/flutter/flutter/issues/162965)
in April 2025 to focus on core framework work — not because it was unpopular
(it still gets thousands of downloads a week). It invited the community to make
**one sustainable fork** rather than many one-off forks.

The community forks that appeared mostly added cosmetic options — none solved
the two things developers actually hit: **`go_router` integration** and **state
loss on resize**. This package does.

| | `flutter_adaptive_scaffold`<br>(discontinued) | Community forks | **`adaptive_scaffold_router`** |
| --- | :---: | :---: | :---: |
| Actively maintained | ❌ | ⚠️ | ✅ |
| Drop-in `AdaptiveScaffold` API | ✅ | ⚠️ renamed | ✅ |
| **`go_router` integration** ([flutter#129850](https://github.com/flutter/flutter/issues/129850)) | ❌ | ❌ | ✅ |
| **State preserved across breakpoints** | ❌ | ❌ | ✅ |
| Cupertino bottom bar | ❌ | ❌ | ✅ |
| Material 3 | ✅ | ✅ | ✅ |

Everything stays **API-compatible** with the original, so migrating is a
one-line import change.

## Features

- 📱 **Adaptive navigation** — bottom bar on phones, rail on tablets, extended
  rail or a permanent drawer on desktop, with smooth animated transitions.
- 🗄️ **Permanent desktop drawer** — opt in with `permanentDrawer: true` to
  surface a persistent `NavigationDrawer` at large widths, the widest tier of
  the Material 3 navigation progression.
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

## Customizing the navigation

**Badges** — compose a Material `Badge` into any destination's icon; it shows in
both the bottom bar and the rail:

```dart
NavigationDestination(
  icon: Badge(label: Text('3'), child: Icon(Icons.inbox)),
  label: 'Inbox',
)
```

**Rail header / footer** — `leadingExtendedNavRail` (or `leadingUnextendedNavRail`)
adds a header above the destinations; `trailingNavRail` adds a footer below them
(shown on the rail at tablet/desktop widths):

```dart
AdaptiveNavigationShell(
  navigationShell: navigationShell,
  leadingExtendedNavRail: const Text('MAIL'),
  trailingNavRail: const Icon(Icons.logout),
  destinations: destinations,
)
```

**Permanent desktop drawer** — set `permanentDrawer: true` to render a persistent
`NavigationDrawer` instead of the extended rail at the large and extra-large
breakpoints. The rail still shows at medium/medium-large widths, and branch
state is preserved when resizing between the two:

```dart
AdaptiveNavigationShell(
  navigationShell: navigationShell,
  permanentDrawer: true,
  destinations: destinations,
)
```

**Cupertino / platform-adaptive bottom bar** — supply a `bottomNavigationBuilder`
to swap the small-breakpoint bar (e.g. a `CupertinoTabBar` on Apple platforms),
or set `cupertino: true` to always use one:

```dart
AdaptiveNavigationShell(
  navigationShell: navigationShell,
  destinations: destinations,
  bottomNavigationBuilder: (context, destinations, index, onSelected) {
    final TargetPlatform platform = Theme.of(context).platform;
    final bool apple = platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;
    return apple
        ? AdaptiveScaffold.cupertinoTabBar(
            destinations: destinations, currentIndex: index, onTap: onSelected)
        : AdaptiveScaffold.standardBottomNavigationBar(
            destinations: destinations, currentIndex: index,
            onDestinationSelected: onSelected);
  },
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

- Cupertino-styled rail/sidebar for Apple desktop (the bottom bar is already
  Cupertino-capable via `bottomNavigationBuilder` / `cupertino`).
- Richer per-destination customization (label visibility, icon transitions).

## 🤝 Contributing

Contributions are welcome! Please feel free to open an
[issue](https://github.com/igloodev/adaptive_scaffold_router/issues) or submit a
Pull Request.

## 📄 License

This project is licensed under the **BSD 3-Clause License** — see the
[LICENSE](LICENSE) file for details. It is derived from `flutter_adaptive_scaffold`
by The Flutter Authors, used under the same license.

## 👨‍💻 Author

Created with ❤️ by [Akhilesh](https://github.com/Akhilesh002) ·
[igloodev](https://igloodev.in)

## 🙏 Acknowledgments

- Built on Google's [`flutter_adaptive_scaffold`](https://pub.dev/packages/flutter_adaptive_scaffold), continued after its discontinuation.
- [Material 3 adaptive design](https://m3.material.io/foundations/adaptive-design/overview) guidelines.
- [`go_router`](https://pub.dev/packages/go_router) for stateful nested navigation.

## 📚 Additional Resources

- [Material 3 — Adaptive design](https://m3.material.io/foundations/adaptive-design/overview)
- [`go_router` documentation](https://pub.dev/packages/go_router)
- [flutter_adaptive_scaffold discontinuation (flutter#162965)](https://github.com/flutter/flutter/issues/162965)

---

If you find this package useful, please give it a ⭐ on
[GitHub](https://github.com/igloodev/adaptive_scaffold_router) and a 👍 on
[pub.dev](https://pub.dev/packages/adaptive_scaffold_router)!
