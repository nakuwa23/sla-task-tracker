import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'more_screen.dart';
import 'task_list_screen.dart';
import 'team_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    TaskListScreen(),
    TeamScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: 'Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
