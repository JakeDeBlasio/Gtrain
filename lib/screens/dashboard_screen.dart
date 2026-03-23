import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_user.dart';
import '../models/training_assignment.dart';
import '../models/training_item.dart';
import '../repositories/training_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';
import '../widgets/status_pill.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.repository,
    this.onNavigate,
  });

  final TrainingRepository repository;
  final void Function(int)? onNavigate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  InkWell(
                    onTap: () => onNavigate?.call(2),
                    borderRadius: BorderRadius.circular(20),
                    child: _CountCard(
                      width: wide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                      title: 'Users',
                      accent: AppTheme.brandBlue,
                      stream: repository.watchUsers(),
                      extractor: (items) => items.length,
                      subtitle: 'Active people in the matrix',
                    ),
                  ),
                  InkWell(
                    onTap: () => onNavigate?.call(3),
                    borderRadius: BorderRadius.circular(20),
                    child: _CountCard(
                      width: wide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                      title: 'Trainings',
                      accent: AppTheme.brandOrange,
                      stream: repository.watchTrainings(),
                      extractor: (items) => items.length,
                      subtitle: 'Policies, SOPs, and recurring certifications',
                    ),
                  ),
                  InkWell(
                    onTap: () => onNavigate?.call(4),
                    borderRadius: BorderRadius.circular(20),
                    child: _CountCard(
                      width: wide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                      title: 'Templates',
                      accent: const Color(0xFF0F766E),
                      stream: repository.watchTemplates(),
                      extractor: (items) => items.length,
                      subtitle: 'Auto-assignment bundles',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Upcoming renewals',
            child: StreamBuilder<List<TrainingAssignment>>(
              stream: repository.watchUpcomingAssignments(),
              builder: (context, snapshot) {
                final assignments = snapshot.data ?? const <TrainingAssignment>[];
                if (assignments.isEmpty) {
                  return const Text('No assignments yet. Add users and apply templates to populate the matrix.');
                }
                return StreamBuilder<List<TrainingItem>>(
                  stream: repository.watchTrainings(),
                  builder: (context, trainingSnapshot) {
                    final trainings = {
                      for (final item in trainingSnapshot.data ?? const <TrainingItem>[]) item.id: item,
                    };
                    return StreamBuilder<List<AppUser>>(
                      stream: repository.watchUsers(),
                      builder: (context, userSnapshot) {
                        final users = {
                          for (final user in userSnapshot.data ?? const <AppUser>[]) user.id: user,
                        };
                        return Column(
                          children: assignments.map((assignment) {
                            final training = trainings[assignment.trainingId];
                            final user = users[assignment.userId];
                            final overdue = assignment.isOverdue;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                border: Border.all(color: Colors.blueGrey.shade50),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          training?.title ?? assignment.trainingId,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${user?.name ?? 'Unknown user'} • Due ${DateFormat.yMMMd().format(assignment.dueAt)}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusPill(
                                    label: overdue ? 'Overdue' : 'Upcoming',
                                    urgent: overdue,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CountCard<T> extends StatelessWidget {
  const _CountCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.stream,
    required this.extractor,
  });

  final double width;
  final String title;
  final String subtitle;
  final Color accent;
  final Stream<List<T>> stream;
  final int Function(List<T>) extractor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: SectionCard(
        title: title,
        child: StreamBuilder<List<T>>(
          stream: stream,
          builder: (context, snapshot) {
            final count = extractor(snapshot.data ?? <T>[]);
            return Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(.12),
                  ),
                  child: Icon(Icons.insights_outlined, color: accent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
