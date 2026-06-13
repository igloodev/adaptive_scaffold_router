// Copyright 2026 igloodev. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold_router/adaptive_scaffold_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(const ExampleApp());

/// Demonstrates [AdaptiveNavigationShell] with `go_router`.
///
/// Resize the window from phone to desktop width: the navigation morphs from a
/// bottom bar to a rail to an extended rail, and the counter / scroll position
/// on each tab is preserved across every change.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'adaptive_scaffold_router',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/inbox',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        return AdaptiveNavigationShell(
          navigationShell: navigationShell,
          // A header (title) and footer, shown on the rail at tablet/desktop.
          leadingExtendedNavRail: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('MAIL',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            ),
          ),
          trailingNavRail: const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Icon(Icons.logout),
          ),
          // Platform-adaptive bottom bar: CupertinoTabBar on Apple platforms,
          // the Material NavigationBar everywhere else.
          bottomNavigationBuilder: (
            BuildContext context,
            List<NavigationDestination> destinations,
            int index,
            ValueChanged<int> onSelected,
          ) {
            final TargetPlatform platform = Theme.of(context).platform;
            final bool apple = platform == TargetPlatform.iOS ||
                platform == TargetPlatform.macOS;
            return apple
                ? AdaptiveScaffold.cupertinoTabBar(
                    destinations: destinations,
                    currentIndex: index,
                    onTap: onSelected,
                  )
                : AdaptiveScaffold.standardBottomNavigationBar(
                    destinations: destinations,
                    currentIndex: index,
                    onDestinationSelected: onSelected,
                  );
          },
          destinations: const <NavigationDestination>[
            // A Badge composes directly into a destination's icon.
            NavigationDestination(
              icon: Badge(label: Text('3'), child: Icon(Icons.inbox_outlined)),
              selectedIcon: Badge(label: Text('3'), child: Icon(Icons.inbox)),
              label: 'Inbox',
            ),
            NavigationDestination(
                icon: Icon(Icons.article_outlined), label: 'Articles'),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
        );
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(path: '/inbox', builder: (_, __) => const _CounterPage()),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
                path: '/articles', builder: (_, __) => const _ArticlesPage()),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
                path: '/settings', builder: (_, __) => const _SettingsPage()),
          ],
        ),
      ],
    ),
  ],
);

/// In-memory counter — proves state survives breakpoint changes.
class _CounterPage extends StatefulWidget {
  const _CounterPage();

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Tapped $_count times',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Resize the window — this count is preserved.'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Long list — proves scroll position survives breakpoint changes.
class _ArticlesPage extends StatelessWidget {
  const _ArticlesPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (_, int i) => ListTile(
          leading: CircleAvatar(child: Text('${i + 1}')),
          title: Text('Article ${i + 1}'),
          subtitle: const Text('Scroll, then resize — your position stays.'),
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings')),
    );
  }
}
