
# Flutter package To Hide widgets on Scroll inside [ListView, GrideView...etc]

## Features

Preview: 

<img src="https://user-images.githubusercontent.com/85020587/228395540-58475a13-6ded-4392-95bd-fd0766408aea.gif" width=25% height=25%>
## Getting started

To use it you need to provide;<br>
    1- ScrollController.<br>
    2- child: Widget that you would like to hide or show(depends on the scroll).<br>
    3- Duration(Optional): how fast to show or hide child widget.<br>
    4- Height: Self Explained.<br>

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
