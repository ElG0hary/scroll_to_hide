
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollToHide extends StatefulWidget {
  const ScrollToHide({
    super.key,
    required this.child,
    required this.scrollController,
    this.duration = const Duration(milliseconds: 300),
    required this.height,
  });

  final Widget child;
  final ScrollController scrollController;
  final Duration duration;
  final double height;

  @override
  State<ScrollToHide> createState() => _ScrollToHideState();
}

class _ScrollToHideState extends State<ScrollToHide> {
  bool isShown = true;

  @override
  void initState() {
    widget.scrollController.addListener(listen);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.duration,
      height: isShown ? widget.height : 0,
      child: Wrap(
        children: [
          widget.child,
        ],
      ),
    );
  }

  void show() {
    if (!isShown) {
      setState(() {
        isShown = true;
      });
    }
  }

  void hide() {
    if (isShown) {
      setState(
        () => isShown = false,
      );
    }
  }

  void listen() {
    final direction = widget.scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.forward) {
      show();
    } else if (direction == ScrollDirection.reverse) {
      hide();
    }
  }
}
