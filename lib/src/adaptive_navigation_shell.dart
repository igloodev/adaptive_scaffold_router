// Copyright 2026 igloodev. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'adaptive_scaffold.dart';
import 'breakpoints.dart';

/// Wires go_router's [StatefulNavigationShell] into an [AdaptiveScaffold],
/// producing a responsive `BottomNavigationBar → NavigationRail → extended
/// rail / Drawer` layout **whose branch state survives breakpoint changes**.
///
/// This is the piece that was missing from `flutter_adaptive_scaffold`: a
/// documented, drop-in way to make adaptive navigation work with `go_router`
/// (see the long-standing request at
/// https://github.com/flutter/flutter/issues/129850) without losing your tabs'
/// scroll position, form input or in-memory state when the window is resized.
///
/// ## Why state is preserved
///
/// Two things combine to keep every branch alive — even when the layout flips
/// from a phone-style bottom bar to a tablet-style rail:
///
/// 1. **go_router** keeps the branches in an `IndexedStack`
///    ([StatefulShellRoute.indexedStack]), so each branch's [Navigator] stays
///    mounted while you switch tabs.
/// 2. **This shell** places that single [navigationShell] widget in the
///    scaffold's body under one stable key for *every* breakpoint. Changing the
///    breakpoint therefore only swaps the navigation chrome (bar ↔ rail ↔
///    drawer); the body subtree is never torn down and rebuilt.
///
/// The original package assigned a different body slot/key per breakpoint, so
/// resizing rebuilt the body from scratch and dropped that state. This shell
/// does not.
///
/// ## Usage
///
/// ```dart
/// final GoRouter router = GoRouter(
///   initialLocation: '/inbox',
///   routes: <RouteBase>[
///     StatefulShellRoute.indexedStack(
///       builder: (BuildContext context, GoRouterState state,
///               StatefulNavigationShell navigationShell) =>
///           AdaptiveNavigationShell(
///         navigationShell: navigationShell,
///         destinations: const <NavigationDestination>[
///           NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
///           NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
///           NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
///         ],
///       ),
///       branches: <StatefulShellBranch>[
///         StatefulShellBranch(routes: <RouteBase>[
///           GoRoute(path: '/inbox', builder: (_, __) => const InboxPage()),
///         ]),
///         StatefulShellBranch(routes: <RouteBase>[
///           GoRoute(path: '/articles', builder: (_, __) => const ArticlesPage()),
///         ]),
///         StatefulShellBranch(routes: <RouteBase>[
///           GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
///         ]),
///       ],
///     ),
///   ],
/// );
/// ```
///
/// The number of [destinations] must match the number of
/// [StatefulShellBranch]es.
///
/// See also:
///
///  * [AdaptiveScaffold], which this shell configures and which can be used
///    directly when you are not using `go_router`.
class AdaptiveNavigationShell extends StatelessWidget {
  /// Creates an [AdaptiveNavigationShell].
  const AdaptiveNavigationShell({
    super.key,
    required this.navigationShell,
    required this.destinations,
    this.appBar,
    this.useDrawer = true,
    this.leadingUnextendedNavRail,
    this.leadingExtendedNavRail,
    this.trailingNavRail,
    this.navigationRailWidth = 72,
    this.extendedNavigationRailWidth = 192,
    this.navigationRailPadding = const EdgeInsets.all(8),
    this.smallBreakpoint = Breakpoints.small,
    this.mediumBreakpoint = Breakpoints.medium,
    this.mediumLargeBreakpoint = Breakpoints.mediumLarge,
    this.largeBreakpoint = Breakpoints.large,
    this.extraLargeBreakpoint = Breakpoints.extraLarge,
    this.drawerBreakpoint = Breakpoints.smallDesktop,
    this.appBarBreakpoint,
    this.transitionDuration = const Duration(milliseconds: 500),
    this.internalAnimations = true,
    this.navigationRailDestinationBuilder,
    this.groupAlignment,
    this.onDestinationSelected,
    this.bottomNavigationBuilder,
    this.cupertino = false,
    this.permanentDrawer = false,
  }) : assert(
          destinations.length >= 2,
          'At least two destinations are required',
        );

  /// The go_router navigation shell created by
  /// [StatefulShellRoute.indexedStack]'s builder.
  ///
  /// Its [StatefulNavigationShell.currentIndex] drives the selected
  /// destination, and tapping a destination calls
  /// [StatefulNavigationShell.goBranch].
  final StatefulNavigationShell navigationShell;

  /// The navigation destinations, one per [StatefulShellBranch], in order.
  final List<NavigationDestination> destinations;

  /// Optional [AppBar] shown when the drawer (or [appBarBreakpoint]) is active.
  ///
  /// Mirrors [AdaptiveScaffold.appBar]. When null and a drawer is shown, a
  /// default [AppBar] is used so the drawer is reachable.
  final PreferredSizeWidget? appBar;

  /// Whether to use a [Drawer] instead of a [BottomNavigationBar] when not on
  /// mobile and the breakpoint is small. Mirrors [AdaptiveScaffold.useDrawer].
  final bool useDrawer;

  /// Leading widget at the top of the unextended (medium) navigation rail.
  final Widget? leadingUnextendedNavRail;

  /// Leading widget at the top of the extended (large) navigation rail.
  final Widget? leadingExtendedNavRail;

  /// Trailing widget below the destinations of the navigation rail.
  final Widget? trailingNavRail;

  /// Width of the unextended [NavigationRail] at the medium breakpoint.
  final double navigationRailWidth;

  /// Width of the extended [NavigationRail] at large breakpoints.
  final double extendedNavigationRailWidth;

  /// Padding applied to the navigation rail.
  final EdgeInsetsGeometry navigationRailPadding;

  /// The breakpoint for the small (mobile) layout. Defaults to
  /// [Breakpoints.small].
  final Breakpoint smallBreakpoint;

  /// The breakpoint for the medium (tablet) layout. Defaults to
  /// [Breakpoints.medium].
  final Breakpoint mediumBreakpoint;

  /// The breakpoint for the mediumLarge layout. Defaults to
  /// [Breakpoints.mediumLarge].
  final Breakpoint mediumLargeBreakpoint;

  /// The breakpoint for the large layout. Defaults to [Breakpoints.large].
  final Breakpoint largeBreakpoint;

  /// The breakpoint for the extraLarge layout. Defaults to
  /// [Breakpoints.extraLarge].
  final Breakpoint extraLargeBreakpoint;

  /// The breakpoint at which a [Drawer] is used. Defaults to
  /// [Breakpoints.smallDesktop].
  final Breakpoint drawerBreakpoint;

  /// Optional breakpoint that forces an [AppBar] independent of the drawer.
  final Breakpoint? appBarBreakpoint;

  /// Duration of the transition between layouts. Defaults to 500ms.
  final Duration transitionDuration;

  /// Whether the secondary body uses the built-in slide transition.
  final bool internalAnimations;

  /// Maps a [NavigationDestination] to a [NavigationRailDestination].
  final NavigationRailDestinationBuilder? navigationRailDestinationBuilder;

  /// Alignment of the destinations within the navigation rail.
  final double? groupAlignment;

  /// Optional callback fired after a destination is selected, in addition to
  /// the branch switch. Useful for analytics or closing transient UI.
  final ValueChanged<int>? onDestinationSelected;

  /// Optional custom bottom navigation builder for the small breakpoint.
  ///
  /// Takes precedence over [cupertino]. See
  /// [AdaptiveScaffold.bottomNavigationBuilder].
  final AdaptiveBottomNavigationBuilder? bottomNavigationBuilder;

  /// When true, the small-breakpoint bottom navigation renders as a
  /// [CupertinoTabBar] instead of a Material [NavigationBar].
  ///
  /// Ignored if [bottomNavigationBuilder] is provided. For platform-adaptive
  /// behavior (Cupertino only on Apple platforms), pass a
  /// [bottomNavigationBuilder] that checks `Theme.of(context).platform` instead.
  final bool cupertino;

  /// When true, the large and extra-large (desktop-class) breakpoints render a
  /// permanent [NavigationDrawer] as the primary navigation instead of the
  /// default extended [NavigationRail]. Mirrors [AdaptiveScaffold.permanentDrawer].
  ///
  /// Branch state is preserved across breakpoints regardless of this flag —
  /// switching between the rail and the drawer never rebuilds the body.
  final bool permanentDrawer;

  AdaptiveBottomNavigationBuilder? get _effectiveBottomNavigationBuilder {
    if (bottomNavigationBuilder != null) return bottomNavigationBuilder;
    if (cupertino) {
      return (
        BuildContext context,
        List<NavigationDestination> destinations,
        int selectedIndex,
        ValueChanged<int> onDestinationSelected,
      ) =>
          AdaptiveScaffold.cupertinoTabBar(
            destinations: destinations,
            currentIndex: selectedIndex,
            onTap: onDestinationSelected,
          );
    }
    return null;
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Returning to the current branch resets it to its initial location,
      // matching the conventional go_router bottom-navigation behavior.
      initialLocation: index == navigationShell.currentIndex,
    );
    onDestinationSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      destinations: destinations,
      selectedIndex: navigationShell.currentIndex,
      onSelectedIndexChange: _goBranch,
      // The single source of body content for *every* breakpoint. Because only
      // `body` is provided (no per-breakpoint bodies), the underlying
      // SlotLayout keeps one stable key, so resizing never rebuilds the
      // navigationShell — preserving each branch's state.
      body: (_) => navigationShell,
      appBar: appBar,
      useDrawer: useDrawer,
      leadingUnextendedNavRail: leadingUnextendedNavRail,
      leadingExtendedNavRail: leadingExtendedNavRail,
      trailingNavRail: trailingNavRail,
      navigationRailWidth: navigationRailWidth,
      extendedNavigationRailWidth: extendedNavigationRailWidth,
      navigationRailPadding: navigationRailPadding,
      smallBreakpoint: smallBreakpoint,
      mediumBreakpoint: mediumBreakpoint,
      mediumLargeBreakpoint: mediumLargeBreakpoint,
      largeBreakpoint: largeBreakpoint,
      extraLargeBreakpoint: extraLargeBreakpoint,
      drawerBreakpoint: drawerBreakpoint,
      appBarBreakpoint: appBarBreakpoint,
      transitionDuration: transitionDuration,
      internalAnimations: internalAnimations,
      navigationRailDestinationBuilder: navigationRailDestinationBuilder,
      groupAlignment: groupAlignment,
      bottomNavigationBuilder: _effectiveBottomNavigationBuilder,
      permanentDrawer: permanentDrawer,
    );
  }
}
