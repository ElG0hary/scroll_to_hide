import 'package:flutter/material.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Scroll To Hide Package Example',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
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
      bottomNavigationBar: ScrollToHide(
        scrollController: _scrollController,
        height: 75,
        hideDirection: Axis.vertical,
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
          backgroundColor: Colors.black.withOpacity(.7),
        ),
      ),
    );
  }
}
