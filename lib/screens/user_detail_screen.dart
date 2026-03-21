import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_user.dart';
import '../models/training_assignment.dart';
import '../models/training_item.dart';
import '../repositories/training_repository.dart';
import '../widgets/section_card.dart';
import '../widgets/status_pill.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({
    super.key,
    required this.repository,
    required this.user,
  });

  final TrainingRepository repository;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: StreamBuilder<List<TrainingItem>>(
          stream: repository.watchTrainings(),
          builder: (context, trainingSnapshot) {
            final trainings = trainingSnapshot.data ?? const <TrainingItem>[];
            final trainingMap = {for (final training in trainings) training.id: training};
            return StreamBuilder<List<TrainingAssignment>>(
              stream: repository.watchAssignmentsForUser(user.id),
              builder: (context, assignmentSnapshot) {
                if (assignmentSnapshot.hasError) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _profileCard(context),
                        const SizedBox(height: 16),
                        SectionCard(
                          title: 'Assigned trainings',
                          child: Text(
                            'Could not load assigned trainings: ${assignmentSnapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final assignments = assignmentSnapshot.data ?? const <TrainingAssignment>[];
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SectionCard(
                        title: 'User profile',
                        trailing: FilledButton.tonalIcon(
                          onPressed: () =>
                              _showManualAssignDialog(context, trainings, assignments),
                          icon: const Icon(Icons.add_task_outlined),
                          label: const Text('Assign training'),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${user.building} • ${user.account}'),
                            const SizedBox(height: 8),
                            Text(user.email.isEmpty ? 'No email added' : user.email),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(label: Text(user.id)),
                                ...user.templateIds
                                    .map((templateId) => Chip(label: Text(templateId))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SectionCard(
                        title: 'Assigned trainings',
                        child: assignments.isEmpty
                            ? const Text('No assignments yet for this user.')
                            : Column(
                                children: assignments.map((assignment) {
                                  final training = trainingMap[assignment.trainingId];
                                  final dueLabel = DateFormat.yMMMd().format(assignment.dueAt);
                                  final isRenewSoon = !assignment.isOverdue &&
                                      assignment.dueAt
                                          .difference(DateTime.now())
                                          .inDays <=
                                      30;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.blueGrey.shade50),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                training?.title ?? assignment.trainingId,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                training?.description.isNotEmpty == true
                                                    ? training!.description
                                                    : 'No description',
                                              ),
                                              const SizedBox(height: 8),
                                              Text('Due: $dueLabel'),
                                              Text('Source: ${assignment.source}'),
                                              if (assignment.completedAt != null)
                                                Text(
                                                  'Last completed: ${DateFormat.yMMMd().format(assignment.completedAt!)}',
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            StatusPill(
                                              label: assignment.isOverdue
                                                  ? 'Overdue'
                                                  : isRenewSoon
                                                      ? 'Renew soon'
                                                      : 'Current',
                                              urgent: assignment.isOverdue,
                                            ),
                                            const SizedBox(height: 10),
                                            FilledButton.icon(
                                              onPressed: training == null
                                                  ? null
                                                  : () => repository.markAssignmentCompleted(
                                                        assignment: assignment,
                                                        training: training,
                                                      ),
                                              icon: const Icon(Icons.check_circle_outline),
                                              label: const Text('Mark complete'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _profileCard(BuildContext context) {
    return SectionCard(
      title: 'User profile',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${user.building} • ${user.account}'),
          const SizedBox(height: 8),
          Text(user.email.isEmpty ? 'No email added' : user.email),
        ],
      ),
    );
  }

  Future<void> _showManualAssignDialog(
    BuildContext context,
    List<TrainingItem> trainings,
    List<TrainingAssignment> assignments,
  ) async {
    final existingTrainingIds = assignments.map((item) => item.trainingId).toSet();
    final available = trainings.where((item) => !existingTrainingIds.contains(item.id)).toList();
    String? selectedId = available.isNotEmpty ? available.first.id : null;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign training manually'),
        content: available.isEmpty
            ? const Text('This user already has every available training assigned.')
            : StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: selectedId,
                    items: available
                        .map(
                          (training) => DropdownMenuItem<String>(
                            value: training.id,
                            child: Text(training.title),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => selectedId = value),
                    decoration: const InputDecoration(labelText: 'Training'),
                  );
                },
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: selectedId == null
                ? null
                : () async {
                    await repository.assignTrainingToUser(
                      userId: user.id,
                      trainingId: selectedId!,
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}
