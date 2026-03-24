import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_user.dart';
import '../models/training_assignment.dart';
import '../models/training_item.dart';
import '../repositories/training_repository.dart';
import '../widgets/section_card.dart';

class CompletedTrainingsScreen extends StatefulWidget {
  const CompletedTrainingsScreen({
    super.key,
    required this.repository,
  });

  final TrainingRepository repository;

  @override
  State<CompletedTrainingsScreen> createState() => _CompletedTrainingsScreenState();
}

class _CompletedTrainingsScreenState extends State<CompletedTrainingsScreen> {
  String _searchTerm = '';
  String? _selectedBuilding;
  String? _selectedAccount;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TrainingAssignment>>(
      stream: widget.repository.watchAssignments(),
      builder: (context, assignmentSnapshot) {
        final allAssignments = assignmentSnapshot.data ?? const <TrainingAssignment>[];
        
        // Filter for completed assignments only
        final completedAssignments = allAssignments
            .where((assignment) => assignment.completedAt != null)
            .toList();

        return StreamBuilder<List<AppUser>>(
          stream: widget.repository.watchUsers(),
          builder: (context, userSnapshot) {
            final allUsers = userSnapshot.data ?? const <AppUser>[];
            
            return StreamBuilder<List<TrainingItem>>(
              stream: widget.repository.watchTrainings(),
              builder: (context, trainingSnapshot) {
                final allTrainings = trainingSnapshot.data ?? const <TrainingItem>[];

                // Get unique buildings and accounts for filter dropdowns
                final buildings = <String>{
                  ...allUsers.map((u) => u.building).where((b) => b.isNotEmpty),
                }.toList()
                  ..sort();

                final accounts = <String>{
                  ...allUsers.map((u) => u.account).where((a) => a.isNotEmpty),
                }.toList()
                  ..sort();

                // Filter completed assignments based on search and filters
                final filteredAssignments = completedAssignments.where((assignment) {
                  final user = allUsers.firstWhere(
                    (u) => u.id == assignment.userId,
                    orElse: () => AppUser.empty(),
                  );
                  final training = allTrainings.firstWhere(
                    (t) => t.id == assignment.trainingId,
                    orElse: () => TrainingItem.empty(),
                  );

                  final matchesSearch = _searchTerm.isEmpty ||
                      user.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                      training.title.toLowerCase().contains(_searchTerm.toLowerCase());
                  final matchesBuilding = _selectedBuilding == null || user.building == _selectedBuilding;
                  final matchesAccount = _selectedAccount == null || user.account == _selectedAccount;
                  
                  return matchesSearch && matchesBuilding && matchesAccount;
                }).toList();

                // Sort by completed date (newest first)
                filteredAssignments.sort((a, b) => (b.completedAt ?? DateTime.now()).compareTo(a.completedAt ?? DateTime.now()));

                return SectionCard(
                  title: 'Completed Trainings',
                  child: Expanded(
                    child: Column(
                      children: [
                        // Search and filter controls
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search field
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search by user name or training title...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onChanged: (value) {
                                  setState(() => _searchTerm = value);
                                },
                              ),
                              const SizedBox(height: 12),
                              // Filter controls
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String?>(
                                      value: _selectedBuilding,
                                      decoration: InputDecoration(
                                        labelText: 'Building',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Text('All Buildings'),
                                        ),
                                        ...buildings.map((building) =>
                                            DropdownMenuItem(
                                              value: building,
                                              child: Text(building),
                                            )),
                                      ],
                                      onChanged: (value) {
                                        setState(() => _selectedBuilding = value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String?>(
                                      value: _selectedAccount,
                                      decoration: InputDecoration(
                                        labelText: 'Account',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Text('All Accounts'),
                                        ),
                                        ...accounts.map((account) =>
                                            DropdownMenuItem(
                                              value: account,
                                              child: Text(account),
                                            )),
                                      ],
                                      onChanged: (value) {
                                        setState(() => _selectedAccount = value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Completed trainings list
                        if (completedAssignments.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text('No completed trainings yet.'),
                            ),
                          )
                        else if (filteredAssignments.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text('No completed trainings match your search and filter criteria.'),
                            ),
                          )
                        else
                          Expanded(
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: filteredAssignments.map((assignment) {
                                  final user = allUsers.firstWhere(
                                    (u) => u.id == assignment.userId,
                                    orElse: () => AppUser.empty(),
                                  );
                                  final training = allTrainings.firstWhere(
                                    (t) => t.id == assignment.trainingId,
                                    orElse: () => TrainingItem.empty(),
                                  );
                                  final completedDate = assignment.completedAt;
                                  final formattedDate = completedDate != null
                                      ? DateFormat('MMM d, yyyy').format(completedDate)
                                      : 'N/A';
                                  final assignedDate = assignment.assignedAt;
                                  final formattedAssignedDate =
                                      DateFormat('MMM d, yyyy').format(assignedDate);

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
                                                training.title,
                                                style: Theme.of(context).textTheme.titleMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'User: ${user.name}',
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${user.building} • ${user.account}',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Assigned: $formattedAssignedDate',
                                                    style: Theme.of(context).textTheme.labelSmall,
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      'Completed: $formattedDate',
                                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                        color: Colors.green[700],
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (training.documentUrl != null && training.documentUrl!.isNotEmpty)
                                          FilledButton.tonal(
                                            onPressed: () {
                                              _openDocument(context, training);
                                            },
                                            child: const Text('View Document'),
                                          )
                                        else
                                          FilledButton.tonal(
                                            onPressed: null,
                                            child: const Text('No Document'),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _openDocument(BuildContext context, TrainingItem training) {
    if (training.documentUrl == null || training.documentUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document available')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${training.title} - Document'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document Name: ${training.documentName ?? "Unknown"}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Document URL:',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                SelectableText(
                  training.documentUrl ?? 'N/A',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
