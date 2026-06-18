// Copyright 2026 igloodev. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold_router/adaptive_scaffold_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const List<NavigationDestination> _destinations = <NavigationDestination>[
  NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
  NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
  NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
];

Future<void> _pump(WidgetTester tester, Size size, Widget child) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: TargetPlatform.android, useMaterial3: true),
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}

// A width comfortably inside Breakpoints.large (1200–1600).
const Size _largeSize = Size(1300, 900);
// A width comfortably inside Breakpoints.extraLarge (>= 1600).
const Size _extraLargeSize = Size(1700, 900);

void main() {
  group('AdaptiveScaffold.standardDrawer', () {
    testWidgets('builds a NavigationDrawer with one destination per item',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const Size(800, 800),
        Scaffold(
          body: AdaptiveScaffold.standardDrawer(
            destinations: _destinations,
            selectedIndex: 0,
          ),
        ),
      );
      expect(find.byType(NavigationDrawer), findsOneWidget);
      expect(find.byType(NavigationDrawerDestination), findsNWidgets(3));
      expect(find.text('Inbox'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('forwards taps with the destination index',
        (WidgetTester tester) async {
      int? tapped;
      await _pump(
        tester,
        const Size(800, 800),
        Scaffold(
          body: AdaptiveScaffold.standardDrawer(
            destinations: _destinations,
            selectedIndex: 0,
            onDestinationSelected: (int i) => tapped = i,
          ),
        ),
      );
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(tapped, 2);
    });

    testWidgets('a leading header does not shift the destination index',
        (WidgetTester tester) async {
      int? tapped;
      await _pump(
        tester,
        const Size(800, 800),
        Scaffold(
          body: AdaptiveScaffold.standardDrawer(
            destinations: _destinations,
            selectedIndex: 0,
            leading: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('BRAND'),
            ),
            onDestinationSelected: (int i) => tapped = i,
          ),
        ),
      );
      expect(find.text('BRAND'), findsOneWidget);
      await tester.tap(find.text('Articles'));
      await tester.pumpAndSettle();
      expect(tapped, 1);
    });
  });

  group('AdaptiveScaffold permanentDrawer', () {
    testWidgets('defaults to the extended rail at the large breakpoint',
        (WidgetTester tester) async {
      await _pump(
        tester,
        _largeSize,
        AdaptiveScaffold(
          destinations: _destinations,
          selectedIndex: 0,
          body: (_) => const SizedBox(),
        ),
      );
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationDrawer), findsNothing);
    });

    testWidgets('renders a permanent NavigationDrawer at the large breakpoint',
        (WidgetTester tester) async {
      await _pump(
        tester,
        _largeSize,
        AdaptiveScaffold(
          destinations: _destinations,
          selectedIndex: 0,
          permanentDrawer: true,
          body: (_) => const SizedBox(),
        ),
      );
      expect(find.byType(NavigationDrawer), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets(
        'renders a permanent NavigationDrawer at the extra-large '
        'breakpoint', (WidgetTester tester) async {
      await _pump(
        tester,
        _extraLargeSize,
        AdaptiveScaffold(
          destinations: _destinations,
          selectedIndex: 0,
          permanentDrawer: true,
          body: (_) => const SizedBox(),
        ),
      );
      expect(find.byType(NavigationDrawer), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('keeps the rail at the medium breakpoint even when enabled',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const Size(800, 800),
        AdaptiveScaffold(
          destinations: _destinations,
          selectedIndex: 0,
          permanentDrawer: true,
          body: (_) => const SizedBox(),
        ),
      );
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationDrawer), findsNothing);
    });
  });

  group('AdaptiveNavigationShell permanentDrawer', () {
    Widget shellApp({required bool permanentDrawer}) {
      final GoRouter router = GoRouter(
        initialLocation: '/a',
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(
            builder: (_, __, StatefulNavigationShell shell) =>
                AdaptiveNavigationShell(
              navigationShell: shell,
              permanentDrawer: permanentDrawer,
              destinations: _destinations,
            ),
            branches: <StatefulShellBranch>[
              StatefulShellBranch(routes: <RouteBase>[
                GoRoute(path: '/a', builder: (_, __) => const Text('BODY A')),
              ]),
              StatefulShellBranch(routes: <RouteBase>[
                GoRoute(path: '/b', builder: (_, __) => const Text('BODY B')),
              ]),
              StatefulShellBranch(routes: <RouteBase>[
                GoRoute(path: '/c', builder: (_, __) => const Text('BODY C')),
              ]),
            ],
          ),
        ],
      );
      return MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(platform: TargetPlatform.android, useMaterial3: true),
      );
    }

    testWidgets('passes permanentDrawer through to the desktop layout',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = _largeSize;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(shellApp(permanentDrawer: true));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationDrawer), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      // Body is still present — the drawer only swaps navigation chrome.
      expect(find.text('BODY A'), findsOneWidget);
    });

    testWidgets(
        'preserves branch state when the body is resized into the '
        'drawer layout', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      // Start at a medium width (rail), then grow to a large width (drawer).
      tester.view.physicalSize = const Size(800, 900);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(shellApp(permanentDrawer: true));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('BODY A'), findsOneWidget);

      tester.view.physicalSize = _largeSize;
      await tester.pumpAndSettle();
      expect(find.byType(NavigationDrawer), findsOneWidget);
      // The same branch body survives the chrome swap.
      expect(find.text('BODY A'), findsOneWidget);
    });
  });
}
