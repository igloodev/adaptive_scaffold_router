// Copyright 2026 igloodev. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold_router/adaptive_scaffold_router.dart';
import 'package:flutter/cupertino.dart' show CupertinoTabBar;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const List<NavigationDestination> _destinations = <NavigationDestination>[
  NavigationDestination(
    icon: Badge(label: Text('3'), child: Icon(Icons.inbox)),
    label: 'Inbox',
  ),
  NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
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

void main() {
  group('badges (Material Badge composes into NavigationDestination.icon)', () {
    testWidgets('render in the bottom bar at the small breakpoint', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const Size(400, 800),
        AdaptiveScaffold(
          destinations: _destinations,
          selectedIndex: 0,
          body: (_) => const SizedBox(),
        ),
      );
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(Badge), findsWidgets);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('render in the navigation rail at the medium breakpoint', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const Size(800, 800),
        AdaptiveScaffold(
          destinations: _destinations,
          selectedIndex: 0,
          body: (_) => const SizedBox(),
        ),
      );
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(Badge), findsWidgets);
    });
  });

  group('Cupertino bottom navigation', () {
    testWidgets(
      'bottomNavigationBuilder replaces the Material bar with a CupertinoTabBar',
      (WidgetTester tester) async {
        await _pump(
          tester,
          const Size(400, 800),
          AdaptiveScaffold(
            destinations: _destinations,
            selectedIndex: 0,
            body: (_) => const SizedBox(),
            bottomNavigationBuilder: (
              BuildContext context,
              List<NavigationDestination> destinations,
              int index,
              ValueChanged<int> onSelected,
            ) =>
                AdaptiveScaffold.cupertinoTabBar(
              destinations: destinations,
              currentIndex: index,
              onTap: onSelected,
            ),
          ),
        );
        expect(find.byType(CupertinoTabBar), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      },
    );

    testWidgets('shell cupertino:true renders a CupertinoTabBar at small width',
        (WidgetTester tester) async {
      final GoRouter router = GoRouter(
        initialLocation: '/a',
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(
            builder: (_, __, StatefulNavigationShell shell) =>
                AdaptiveNavigationShell(
              navigationShell: shell,
              cupertino: true,
              destinations: const <NavigationDestination>[
                NavigationDestination(icon: Icon(Icons.home), label: 'A'),
                NavigationDestination(icon: Icon(Icons.settings), label: 'B'),
              ],
            ),
            branches: <StatefulShellBranch>[
              StatefulShellBranch(routes: <RouteBase>[
                GoRoute(path: '/a', builder: (_, __) => const Text('A')),
              ]),
              StatefulShellBranch(routes: <RouteBase>[
                GoRoute(path: '/b', builder: (_, __) => const Text('B')),
              ]),
            ],
          ),
        ],
      );
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(platform: TargetPlatform.android),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoTabBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('navigation rail header & footer', () {
    testWidgets('leading and trailing widgets render on the rail (medium)', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const Size(800, 800),
        AdaptiveScaffold(
          destinations: _destinations,
          selectedIndex: 0,
          body: (_) => const SizedBox(),
          leadingUnextendedNavRail: const Text('HEADER'),
          trailingNavRail: const Text('FOOTER'),
        ),
      );
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('HEADER'), findsOneWidget);
      expect(find.text('FOOTER'), findsOneWidget);
    });
  });
}
