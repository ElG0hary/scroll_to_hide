import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Controls a [ScrollToHide] widget from outside of the scroll listener.
///
/// This is useful when navigation or app state changes should restore the
/// widget even though no scroll gesture happened, for example after returning
/// from a details route.
class ScrollToHideController extends ChangeNotifier {
  /// Creates a controller with an optional initial visibility value.
  ScrollToHideController({bool initiallyVisible = true})
    : _isVisible = initiallyVisible;

  bool _isVisible;

  /// Whether the attached [ScrollToHide] is currently shown.
  bool get isVisible => _isVisible;

  /// Shows the attached [ScrollToHide] if it is hidden.
  void show() {
    _setVisible(true);
  }

  /// Hides the attached [ScrollToHide] if it is shown.
  void hide() {
    _setVisible(false);
  }

  /// Toggles the attached [ScrollToHide] visibility.
  void toggle() {
    _setVisible(!_isVisible);
  }

  void _setVisible(bool value) {
    if (_isVisible == value) {
      return;
    }

    _isVisible = value;
    notifyListeners();
  }
}

/// A widget that hides its child when the user scrolls down and shows it again
/// when the user scrolls up.
///
/// This behavior is commonly used to hide elements like a bottom navigation bar
/// to provide a more immersive user experience.
class ScrollToHide extends StatefulWidget {
  /// Creates a `ScrollToHide` widget.
  ///
  /// The [child] and [scrollController] parameters are required.
  ///
  /// The [child] is the widget that you want to hide/show based on the scroll
  /// direction.
  ///
  /// The [scrollController] must be attached to the scrollable widget that
  /// drives visibility changes.
  ///
  /// Provide [height] for vertical bars and [width] for horizontal panels when
  /// you want the shown size to be fixed.
  const ScrollToHide({
    super.key,
    required this.child,
    required this.scrollController,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
    this.hideDirection = Axis.vertical,
    this.width,
    this.height,
    this.controller,
    this.routeObserver,
    this.autoShowOnRoutePop = true,
    this.enabled = true,
    this.initiallyVisible = true,
    this.clipBehavior = Clip.hardEdge,
    this.onVisibilityChanged,
  });

  /// The widget that you want to hide/show based on the scroll direction.
  final Widget child;

  /// The `ScrollController` connected to the scrollable widget in your app.
  ///
  /// This tracks the user scroll direction and determines whether to hide or
  /// show the child widget.
  final ScrollController scrollController;

  /// The duration of the animation when the child widget is hidden or shown.
  final Duration duration;

  /// The curve of the hide/show animation.
  final Curve curve;

  /// The shown height of the child widget.
  ///
  /// When [hideDirection] is [Axis.vertical], the height will be animated to 0.
  final double? height;

  /// The axis that shrinks when the widget hides.
  final Axis hideDirection;

  /// The initial width of the child widget. When [hideDirection] is
  /// [Axis.horizontal], the width will be animated to 0.
  final double? width;

  /// Optional controller for showing, hiding, or reading visibility manually.
  final ScrollToHideController? controller;

  /// Optional route observer used to show the child again when a covered route
  /// is popped.
  ///
  /// Register the same observer in `MaterialApp.navigatorObservers`.
  final RouteObserver<ModalRoute<void>>? routeObserver;

  /// Whether [didPopNext] should show the child when [routeObserver] notifies
  /// that a route above this one was popped.
  final bool autoShowOnRoutePop;

  /// Whether scroll events should update visibility.
  ///
  /// Manual controller calls still work while this is false.
  final bool enabled;

  /// Initial visibility when [controller] is not provided.
  final bool initiallyVisible;

  /// Clips the child while it animates out of view.
  final Clip clipBehavior;

  /// Called when visibility changes from scroll, route, or controller actions.
  final ValueChanged<bool>? onVisibilityChanged;

  @override
  State<ScrollToHide> createState() => _ScrollToHideState();
}

class _ScrollToHideState extends State<ScrollToHide> with RouteAware {
  late ScrollToHideController _controller;
  ScrollToHideController? _ownedController;
  RouteObserver<ModalRoute<void>>? _subscribedObserver;

  @override
  void initState() {
    super.initState();
    _attachController();
    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRouteSubscription();
  }

  @override
  void didUpdateWidget(covariant ScrollToHide oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_handleScroll);
      widget.scrollController.addListener(_handleScroll);
    }

    if (oldWidget.controller != widget.controller) {
      _detachController();
      _attachController();
    }

    if (oldWidget.routeObserver != widget.routeObserver ||
        oldWidget.autoShowOnRoutePop != widget.autoShowOnRoutePop) {
      _updateRouteSubscription();
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    _unsubscribeFromRoute();
    _detachController();
    super.dispose();
  }

  @override
  void didPopNext() {
    if (widget.autoShowOnRoutePop) {
      _controller.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final factor = _controller.isVisible ? 1.0 : 0.0;
    final isVertical = widget.hideDirection == Axis.vertical;

    return ClipRect(
      clipBehavior: widget.clipBehavior,
      child: AnimatedSize(
        duration: widget.duration,
        curve: widget.curve,
        alignment: _alignment,
        child: Align(
          alignment: _alignment,
          heightFactor: isVertical ? factor : 1,
          widthFactor: isVertical ? 1 : factor,
          child: SizedBox(
            height: widget.height,
            width: widget.width,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  AlignmentGeometry get _alignment {
    return switch (widget.hideDirection) {
      Axis.horizontal => Alignment.centerLeft,
      Axis.vertical => Alignment.topCenter,
    };
  }

  void _attachController() {
    _ownedController =
        widget.controller == null
            ? ScrollToHideController(initiallyVisible: widget.initiallyVisible)
            : null;
    _controller = widget.controller ?? _ownedController!;
    _controller.addListener(_handleControllerChanged);
  }

  void _detachController() {
    _controller.removeListener(_handleControllerChanged);
    _ownedController?.dispose();
    _ownedController = null;
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }

    widget.onVisibilityChanged?.call(_controller.isVisible);
    setState(() {});
  }

  void _updateRouteSubscription() {
    _unsubscribeFromRoute();

    if (!widget.autoShowOnRoutePop || widget.routeObserver == null) {
      return;
    }

    final route = ModalRoute.of<void>(context);
    if (route == null) {
      return;
    }

    widget.routeObserver!.subscribe(this, route);
    _subscribedObserver = widget.routeObserver;
  }

  void _unsubscribeFromRoute() {
    if (_subscribedObserver == null) {
      return;
    }

    _subscribedObserver!.unsubscribe(this);
    _subscribedObserver = null;
  }

  void _handleScroll() {
    if (!widget.enabled || !widget.scrollController.hasClients) {
      return;
    }

    final direction = widget.scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.forward) {
      _controller.show();
    } else if (direction == ScrollDirection.reverse) {
      _controller.hide();
    }
  }
}
