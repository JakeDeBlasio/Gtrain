import 'package:flutter/material.dart';

import '../repositories/training_repository.dart';
import '../theme/app_theme.dart';
import 'compliance_matrix_screen.dart';
import 'dashboard_screen.dart';
import 'templates_screen.dart';
import 'trainings_screen.dart';
import 'users_screen.dart';

class TrainingMatrixShell extends StatefulWidget {
  const TrainingMatrixShell({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  State<TrainingMatrixShell> createState() => _TrainingMatrixShellState();
}

class _TrainingMatrixShellState extends State<TrainingMatrixShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final screens = [
      DashboardScreen(repository: widget.repository),
      ComplianceMatrixScreen(repository: widget.repository),
      UsersScreen(repository: widget.repository),
      TrainingsScreen(repository: widget.repository),
      TemplatesScreen(repository: widget.repository),
    ];

    final destinations = const [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Overview'),
      NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Matrix'),
      NavigationDestination(icon: Icon(Icons.people_alt_outlined), label: 'Users'),
      NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Trainings'),
      NavigationDestination(icon: Icon(Icons.auto_awesome_motion_outlined), label: 'Templates'),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 88,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Training Matrix',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            const Text('GEODIS styled training administration for web, iOS, and Android.'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 24),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.brandBlue,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandBlue.withOpacity(.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.cloud_done_outlined, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Firebase live',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFF), Color(0xFFF4F6FB)],
          ),
        ),
        child: Row(
          children: [
            if (wide)
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: (value) => setState(() => _index = value),
                extended: true,
                minExtendedWidth: 200,
                labelType: NavigationRailLabelType.none,
                leading: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.brandBlue, AppTheme.brandOrange],
                      ),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, color: Colors.white),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    label: Text('Overview'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.grid_view_rounded),
                    label: Text('Matrix'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_alt_outlined),
                    label: Text('Users'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    label: Text('Trainings'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.auto_awesome_motion_outlined),
                    label: Text('Templates'),
                  ),
                ],
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: screens[_index],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              destinations: destinations,
              onDestinationSelected: (value) => setState(() => _index = value),
            ),
    );
  }
}
