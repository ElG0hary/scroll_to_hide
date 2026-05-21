# ScrollToHide

A small Flutter widget for hiding or showing any child when the user scrolls.
It is commonly used for bottom navigation bars, floating action areas, headers,
or side panels.

## Features

- Hide on reverse scroll and show on forward scroll.
- Vertical and horizontal hide animations.
- Optional `ScrollToHideController` for manual show, hide, toggle, and state reads.
- Optional `RouteObserver` support to show the child again when returning from a pushed route.
- Works with any `ScrollController` attached to a Flutter scrollable.

## Installation

```yaml
dependencies:
  scroll_to_hide: ^2.3.0
```

## Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';

class ScrollToHideExample extends StatefulWidget {
  const ScrollToHideExample({super.key});

  @override
  State<ScrollToHideExample> createState() => _ScrollToHideExampleState();
}

class _ScrollToHideExampleState extends State<ScrollToHideExample> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        controller: _scrollController,
        itemCount: 100,
        itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
      ),
      bottomNavigationBar: ScrollToHide(
        scrollController: _scrollController,
        height: 72,
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
```

## Restore After Navigation

If a widget is hidden before navigating away, it can remain hidden when the user
returns to a non-scrollable screen. You can restore it automatically by passing a
registered `RouteObserver`.

```dart
final routeObserver = RouteObserver<ModalRoute<void>>();

MaterialApp(
  navigatorObservers: [routeObserver],
  home: HomeScreen(routeObserver: routeObserver),
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.routeObserver});

  final RouteObserver<ModalRoute<void>> routeObserver;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(controller: scrollController),
      bottomNavigationBar: ScrollToHide(
        scrollController: scrollController,
        routeObserver: widget.routeObserver,
        height: 72,
        child: const YourBottomBar(),
      ),
    );
  }
}
```

For nested navigators or custom routing setups, use a controller and call
`show()` when your route or tab changes.

```dart
final scrollController = ScrollController();
final hideController = ScrollToHideController();

ScrollToHide(
  scrollController: scrollController,
  controller: hideController,
  height: 72,
  child: const YourBottomBar(),
);

// For example, after a back button, save action, or tab change:
hideController.show();
```

Dispose controllers you create:

```dart
@override
void dispose() {
  hideController.dispose();
  scrollController.dispose();
  super.dispose();
}
```

## Horizontal Hide

```dart
ScrollToHide(
  scrollController: scrollController,
  hideDirection: Axis.horizontal,
  width: 280,
  child: const NavigationRail(),
);
```

## Constructor Parameters

| Parameter | Required | Default | Description |
| --- | --- | --- | --- |
| `child` | yes | - | Widget to hide or show. |
| `scrollController` | yes | - | Controller attached to the scrollable. |
| `duration` | no | `Duration(milliseconds: 300)` | Hide/show animation duration. |
| `curve` | no | `Curves.linear` | Hide/show animation curve. |
| `hideDirection` | no | `Axis.vertical` | Axis that shrinks when hidden. |
| `height` | no | `null` | Fixed shown height, useful for vertical bars. |
| `width` | no | `null` | Fixed shown width, useful for horizontal panels. |
| `controller` | no | `null` | Manual visibility controller. |
| `routeObserver` | no | `null` | Observer for automatic show on route pop. |
| `autoShowOnRoutePop` | no | `true` | Shows when `didPopNext` is received. |
| `enabled` | no | `true` | Enables scroll-driven visibility changes. |
| `initiallyVisible` | no | `true` | Initial state when no controller is supplied. |
| `clipBehavior` | no | `Clip.hardEdge` | Clips the child during animation. |
| `onVisibilityChanged` | no | `null` | Callback when visibility changes. |

## Notes

- Use the same `ScrollController` for `ScrollToHide` and the scrollable you want
  to observe.
- Provide `height` for vertical bars and `width` for horizontal panels when you
  want a stable shown size.
- Use `RouteObserver` for regular pushed routes. Use `ScrollToHideController`
  for nested navigators, tab shells, and custom back/save flows.
