// Copyright 2026 igloodev. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold_router/adaptive_scaffold_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpAt(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: child));
}

void main() {
  testWidgets('Breakpoints.small is active below 600dp', (
    WidgetTester tester,
  ) async {
    late bool smallActive;
    late bool mediumActive;
    await _pumpAt(
      tester,
      const Size(400, 800),
      Builder(
        builder: (BuildContext context) {
          smallActive = Breakpoints.small.isActive(context);
          mediumActive = Breakpoints.medium.isActive(context);
          return const SizedBox();
        },
      ),
    );

    expect(smallActive, isTrue);
    expect(mediumActive, isFalse);
  });

  testWidgets('Breakpoints.medium is active between 600 and 840dp', (
    WidgetTester tester,
  ) async {
    late bool smallActive;
    late bool mediumActive;
    await _pumpAt(
      tester,
      const Size(700, 800),
      Builder(
        builder: (BuildContext context) {
          smallActive = Breakpoints.small.isActive(context);
          mediumActive = Breakpoints.medium.isActive(context);
          return const SizedBox();
        },
      ),
    );

    expect(smallActive, isFalse);
    expect(mediumActive, isTrue);
  });

  test('Breakpoint comparison operators behave as ordered', () {
    expect(Breakpoints.medium > Breakpoints.small, isTrue);
    expect(Breakpoints.small < Breakpoints.large, isTrue);
    expect(Breakpoints.medium >= Breakpoints.medium, isTrue);
    expect(Breakpoints.small <= Breakpoints.small, isTrue);
  });
}
