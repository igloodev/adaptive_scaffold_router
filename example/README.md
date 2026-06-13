# adaptive_scaffold_router example

A runnable demo of [`adaptive_scaffold_router`](https://pub.dev/packages/adaptive_scaffold_router).

It wires three `go_router` branches (Inbox, Articles, Settings) into an
`AdaptiveNavigationShell`. Run it and resize the window:

- the navigation morphs `BottomNavigationBar → NavigationRail → extended rail`;
- the Inbox counter and the Articles scroll position are **preserved** across
  every resize and tab switch.

```sh
cd example
flutter run -d chrome   # or any device; resize the window to see it adapt
```

See [`lib/main.dart`](lib/main.dart) for the full source.
