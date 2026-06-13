// Copyright 2013 The Flutter Authors. All rights reserved.
// Copyright 2026 igloodev. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Adaptive Material 3 navigation scaffold for Flutter.
///
/// A drop-in successor to the discontinued `flutter_adaptive_scaffold`, adding
/// first-class [go_router](https://pub.dev/packages/go_router) integration via
/// [AdaptiveNavigationShell] and state preservation across breakpoint changes.
///
/// The core widgets ([AdaptiveScaffold], [AdaptiveLayout], [SlotLayout] and
/// [Breakpoint]/[Breakpoints]) are API-compatible with `flutter_adaptive_scaffold`
/// 0.3.x, so migrating is usually a one-line import change.
library;

export 'src/adaptive_layout.dart';
export 'src/adaptive_navigation_shell.dart';
export 'src/adaptive_scaffold.dart';
export 'src/breakpoints.dart';
export 'src/slot_layout.dart';
