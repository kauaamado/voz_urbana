import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import 'map_screen.dart';
import 'timeline_screen.dart';
import 'new_occurrence_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MapScreen(),
    const TimelineScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voz Urbana', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Registrar nova ocorrência',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewOccurrenceScreen()),
          );
        },
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Registrar'),
        backgroundColor: DesignSystem.primary,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_timeline_outlined),
            activeIcon: Icon(Icons.view_timeline),
            label: 'Linha do Tempo',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: DesignSystem.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
