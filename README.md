# ScrollToHide Flutter Package

The ScrollToHide package is a Flutter plugin designed to hide a widget (e.g., a bottom navigation bar) when the user scrolls down and show it again when the user scrolls up. This behavior is commonly used to provide a more immersive and distraction-free user experience in applications.

## Installation

To use the ScrollToHide package, add it as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  scroll_to_hide: ^2.0.0 
  ```

## Usage
 1- Import the ScrollToHide package in your Dart file:
  ```
    import 'package:flutter/material.dart';
    import 'package:scroll_to_hide/scroll_to_hide.dart';
  ```
 2- Wrap the widget you want to hide when scrolling with the ScrollToHide widget:
  ```
  ScrollToHide(
    scrollController: _yourScrollController,
    height: _desiredHeight, // The initial height of the widget.
    duration: Duration(milliseconds: 300), // Duration of the hide/show animation.
    child: YourWidgetToHide(),
  ),
  ```
## Constructor Parameters
  The ScrollToHide widget has the following constructor parameters:

scrollController (required): The ScrollController that is connected to the scrollable widget in your app. This is used to track the scroll position and determine whether to hide or show the child widget.

child (required): The widget that you want to hide/show based on the scroll direction.

height (required): The initial height of the child widget. When the widget is hidden, its height will be animated to 0.

duration: The duration of the animation when the child widget is hidden or shown. By default, it is set to Duration(milliseconds: 300).

## Methods
  The ScrollToHide widget provides two methods that allow you to manually show or hide the child widget:

  1- void show(): This method shows the child widget if it is currently hidden.

  1- void hide(): This method hides the child widget if it is currently shown.
## Preview:

<img src="https://user-images.githubusercontent.com/85020587/228395540-58475a13-6ded-4392-95bd-fd0766408aea.gif">

## Usage

```
  import 'package:flutter/material.dart';
  import 'package:scroll_to_hide/scroll_to_hide.dart';

  class MyApp extends StatelessWidget {
    final _scrollController = ScrollController();

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('Scroll To Hide Example')),
        body: ScrollToHide(
          scrollController: _scrollController,
          height: 50, // Initial height of the bottom navigation bar.
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        ),
      );
    }
  }
```
In this example, the BottomNavigationBar will be hidden when the user scrolls down and shown again when the user scrolls up.

## Notes
The ScrollToHide widget relies on the ScrollController to track the scroll position. Make sure to initialize and dispose of the ScrollController properly to avoid memory leaks.

It is essential to provide a reasonable value for the height parameter to ensure that the widget has the correct initial height when shown for the first time.

The package uses an AnimatedContainer internally to animate the hide/show transitions. For this reason, it is recommended to use lightweight widgets as the child of ScrollToHide for smooth animations.

## Additional information

This is Github package Link
<https://github.com/ElG0hary/scroll_to_hide>
