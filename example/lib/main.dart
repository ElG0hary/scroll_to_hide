import 'package:flutter/material.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';

final routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll To Hide Package Example',
      navigatorObservers: [routeObserver],
      home: HomeScreen(routeObserver: routeObserver),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.routeObserver});

  final RouteObserver<ModalRoute<void>> routeObserver;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: _scrollController,
        children: List.generate(
          100,
          (index) => Text(
            index.toString(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const DetailsScreen(),
            ),
          );
        },
        child: const Icon(Icons.open_in_new),
      ),
      bottomNavigationBar: ScrollToHide(
        scrollController: _scrollController,
        height: 75,
        routeObserver: widget.routeObserver,
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Colors.white,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite_outline,
                color: Colors.white,
              ),
              label: 'Favourite',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              label: 'Setting',
            ),
          ],
          backgroundColor: Colors.black.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: ListView.builder(
        itemCount: 60,
        itemBuilder: (_, index) => ListTile(title: Text('Details item $index')),
      ),
    );
  }
}
