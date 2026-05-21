import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';

const _barKey = Key('scroll-to-hide-bar');
const _openDetailsKey = Key('open-details');
const _duration = Duration(milliseconds: 80);
const _barExtent = 72.0;

void main() {
  testWidgets('hides on reverse scroll and shows on forward scroll', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await _pumpApp(
      tester,
      scrollController: scrollController,
      child: ScrollToHide(
        key: _barKey,
        scrollController: scrollController,
        height: _barExtent,
        duration: _duration,
        child: const _BottomBar(),
      ),
    );

    expect(_barHeight(tester), _barExtent);

    await _dragList(tester, offset: const Offset(0, -300));

    expect(_barHeight(tester), 0);

    await _dragList(tester, offset: const Offset(0, 300));

    expect(_barHeight(tester), _barExtent);
  });

  testWidgets('shows automatically when a covered route is popped', (
    tester,
  ) async {
    final scrollController = ScrollController();
    final routeObserver = RouteObserver<ModalRoute<void>>();
    addTearDown(scrollController.dispose);

    await _pumpApp(
      tester,
      scrollController: scrollController,
      navigatorObservers: [routeObserver],
      child: ScrollToHide(
        key: _barKey,
        scrollController: scrollController,
        height: _barExtent,
        duration: _duration,
        routeObserver: routeObserver,
        child: const _BottomBar(),
      ),
    );

    await _dragList(tester, offset: const Offset(0, -300));
    expect(_barHeight(tester), 0);

    await tester.tap(find.byKey(_openDetailsKey));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(_barHeight(tester), _barExtent);
  });

  testWidgets('controller can restore visibility after navigation', (
    tester,
  ) async {
    final scrollController = ScrollController();
    final hideController = ScrollToHideController();
    addTearDown(scrollController.dispose);
    addTearDown(hideController.dispose);

    await _pumpApp(
      tester,
      scrollController: scrollController,
      child: ScrollToHide(
        key: _barKey,
        scrollController: scrollController,
        controller: hideController,
        height: _barExtent,
        duration: _duration,
        child: const _BottomBar(),
      ),
    );

    await _dragList(tester, offset: const Offset(0, -300));
    expect(_barHeight(tester), 0);
    expect(hideController.isVisible, isFalse);

    await tester.tap(find.byKey(_openDetailsKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    hideController.show();
    await tester.pumpAndSettle();

    expect(_barHeight(tester), _barExtent);
    expect(hideController.isVisible, isTrue);
  });

  testWidgets('moves its listener when the scroll controller changes', (
    tester,
  ) async {
    final firstScrollController = ScrollController();
    final secondScrollController = ScrollController();
    final swapKey = GlobalKey<_ControllerSwapHostState>();
    addTearDown(firstScrollController.dispose);
    addTearDown(secondScrollController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: _ControllerSwapHost(
          key: swapKey,
          firstScrollController: firstScrollController,
          secondScrollController: secondScrollController,
        ),
      ),
    );

    await _dragList(tester, offset: const Offset(0, -300));
    expect(_barHeight(tester), 0);

    swapKey.currentState!.swapScrollController();
    await tester.pumpAndSettle();

    await _dragList(tester, offset: const Offset(0, 300));
    expect(_barHeight(tester), 0);

    await _dragSecondList(tester, offset: const Offset(0, -300));
    expect(_barHeight(tester), 0);

    await _dragSecondList(tester, offset: const Offset(0, 300));
    expect(_barHeight(tester), _barExtent);
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required ScrollController scrollController,
  required Widget child,
  List<NavigatorObserver> navigatorObservers = const [],
}) {
  return tester.pumpWidget(
    MaterialApp(
      navigatorObservers: navigatorObservers,
      home: Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: ListView.builder(
          controller: scrollController,
          itemCount: 40,
          itemBuilder:
              (_, index) => SizedBox(height: 60, child: Text('Item $index')),
        ),
        floatingActionButton: const _OpenDetailsButton(),
        bottomNavigationBar: child,
      ),
    ),
  );
}

Future<void> _dragList(WidgetTester tester, {required Offset offset}) async {
  await tester.drag(find.byType(ListView).first, offset);
  await tester.pumpAndSettle();
}

Future<void> _dragSecondList(
  WidgetTester tester, {
  required Offset offset,
}) async {
  await tester.drag(find.byType(ListView).last, offset);
  await tester.pumpAndSettle();
}

double _barHeight(WidgetTester tester) =>
    tester.getSize(find.byKey(_barKey)).height;

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: _barExtent, child: Text('Bottom bar'));
  }
}

class _OpenDetailsButton extends StatelessWidget {
  const _OpenDetailsButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: _openDetailsKey,
      onPressed: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder:
                (_) => Scaffold(
                  appBar: AppBar(title: const Text('Details')),
                  body: const SizedBox.expand(),
                ),
          ),
        );
      },
      child: const Icon(Icons.open_in_new),
    );
  }
}

class _ControllerSwapHost extends StatefulWidget {
  const _ControllerSwapHost({
    super.key,
    required this.firstScrollController,
    required this.secondScrollController,
  });

  final ScrollController firstScrollController;
  final ScrollController secondScrollController;

  @override
  State<_ControllerSwapHost> createState() => _ControllerSwapHostState();
}

class _ControllerSwapHostState extends State<_ControllerSwapHost> {
  late ScrollController _activeScrollController = widget.firstScrollController;

  void swapScrollController() {
    setState(() {
      _activeScrollController = widget.secondScrollController;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: widget.firstScrollController,
              itemCount: 40,
              itemBuilder:
                  (_, index) =>
                      SizedBox(height: 60, child: Text('First $index')),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: widget.secondScrollController,
              itemCount: 40,
              itemBuilder:
                  (_, index) =>
                      SizedBox(height: 60, child: Text('Second $index')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ScrollToHide(
        key: _barKey,
        scrollController: _activeScrollController,
        height: _barExtent,
        duration: _duration,
        child: const _BottomBar(),
      ),
    );
  }
}
