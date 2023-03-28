
# Flutter package To Hide widgets on Scroll inside [ListView, GrideView...etc]

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

To use it you need to provide;
    1- ScrollController.
    2- child: Widget that you would like to hide or show(depends on the scroll).
    3- Duration(Optional): how fast to show or hide child widget.
    4- Height: Self Explained.

## Usage

```An Example of using it with BottomNavBar:

    class ScrollToHide extends StatelessWidget {
  const ScrollToHide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScrolToHide Package'),
      ),
      bottomNavigationBar: ScrollToHideNavBar(
            controller: bottomNavScrollController,
            height: 72,
            child: const BottomNavBar(),
          ),
    );
  }
} 

```

## Additional information

This is Github package Link
<https://github.com/ElG0hary/scroll_to_hide>
