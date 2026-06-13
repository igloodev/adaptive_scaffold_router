// Copyright 2026 igloodev. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold_router/adaptive_scaffold_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// A page that holds in-memory state (a counter) so tests can prove the state
/// survives layout/breakpoint changes.
class _CounterPage extends StatefulWidget {
  const _CounterPage();

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('count: $count'),
          ElevatedButton(
            onPressed: () => setState(() => count++),
            child: const Text('inc'),
          ),
        ],
      ),
    );
  }
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/a',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return AdaptiveNavigationShell(
            navigationShell: navigationShell,
            destinations: const <NavigationDestination>[
              NavigationDestination(icon: Icon(Icons.home), label: 'A'),
              NavigationDestination(icon: Icon(Icons.settings), label: 'B'),
            ],
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: '/a', builder: (_, __) => const _CounterPage()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/b',
                builder: (_, __) => const Center(child: Text('B page')),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Future<void> _pumpShell(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp.router(routerConfig: _buildRouter()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('preserves branch state across a breakpoint change', (
    WidgetTester tester,
  ) async {
    // Start phone-sized: a bottom navigation bar.
    await _pumpShell(tester, const Size(400, 800));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    // Build up some in-memory state on the active branch.
    for (int i = 0; i < 3; i++) {
      await tester.tap(find.text('inc'));
      await tester.pump();
    }
    expect(find.text('count: 3'), findsOneWidget);

    // Resize to tablet width: the chrome must switch to a rail...
    tester.view.physicalSize = const Size(800, 800);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // ...and the counter state must NOT have been lost. This is the behaviour
    // the original flutter_adaptive_scaffold could not guarantee.
    expect(find.text('count: 3'), findsOneWidget);
  });

  testWidgets('switching branches and back preserves each branch state', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester, const Size(400, 800));

    // Increment on branch A.
    await tester.tap(find.text('inc'));
    await tester.pump();
    expect(find.text('count: 1'), findsOneWidget);

    // Go to branch B.
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('B page'), findsOneWidget);

    // Return to branch A — its counter state is intact.
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(find.text('count: 1'), findsOneWidget);
  });

  testWidgets('tapping a destination navigates to that branch', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester, const Size(400, 800));
    expect(find.text('count: 0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('B page'), findsOneWidget);
  });
}
