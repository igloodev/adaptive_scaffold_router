// Copyright 2026 igloodev. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold_router/adaptive_scaffold_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const List<NavigationDestination> _destinations = <NavigationDestination>[
  NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
  NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
  NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
];

Future<void> _pumpScaffold(
  WidgetTester tester,
  Size size, {
  ValueChanged<int>? onSelected,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: AdaptiveScaffold(
        destinations: _destinations,
        selectedIndex: 0,
        onSelectedIndexChange: onSelected,
        body: (_) => const Center(child: Text('body content')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows a NavigationBar (not a rail) on a small screen', (
    WidgetTester tester,
  ) async {
    await _pumpScaffold(tester, const Size(400, 800));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('body content'), findsOneWidget);
  });

  testWidgets('shows a NavigationRail (not a bottom bar) on a medium screen', (
    WidgetTester tester,
  ) async {
    await _pumpScaffold(tester, const Size(700, 800));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('body content'), findsOneWidget);
  });

  testWidgets('reports the tapped destination via onSelectedIndexChange', (
    WidgetTester tester,
  ) async {
    int? selected;
    await _pumpScaffold(
      tester,
      const Size(400, 800),
      onSelected: (int i) => selected = i,
    );

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();

    expect(selected, 2);
  });

  testWidgets('asserts when fewer than two destinations are provided', (
    WidgetTester tester,
  ) async {
    expect(
      () => AdaptiveScaffold(
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
        ],
        body: (_) => const SizedBox(),
      ),
      throwsAssertionError,
    );
  });
}
