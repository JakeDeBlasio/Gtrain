import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_user.dart';
import '../models/training_assignment.dart';
import '../models/training_item.dart';
import '../repositories/training_repository.dart';

class ComplianceMatrixScreen extends StatefulWidget {
  const ComplianceMatrixScreen({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  State<ComplianceMatrixScreen> createState() => _ComplianceMatrixScreenState();
}

class _ComplianceMatrixScreenState extends State<ComplianceMatrixScreen> {
  static const String _allBuildings = 'All buildings';
  static const String _allAccounts = 'All accounts';

  String _selectedBuilding = _allBuildings;
  String _selectedAccount = _allAccounts;

  static const Color _navy = Color(0xFF011956);
  static const Color _grid = Color(0xFFD9DFEA);
  static const Color _surface = Colors.white;
  static const Color _page = Color(0xFFF4F6FA);
  static const Color _text = Color(0xFF1A2233);
  static const Color _muted = Color(0xFF697386);
  static const Color _green = Color(0xFF1E8E3E);
  static const Color _greenBg = Color(0xFFE7F6EC);
  static const Color _yellow = Color(0xFFC58A00);
  static const Color _yellowBg = Color(0xFFFFF4D6);
  static const Color _red = Color(0xFFD93025);
  static const Color _redBg = Color(0xFFFCE8E6);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: widget.repository.watchUsers(),
      builder: (context, userSnapshot) {
        final users = userSnapshot.data ?? const <AppUser>[];
        final buildings = <String>{
          _allBuildings,
          ...users.map((u) => u.building.trim()).where((v) => v.isNotEmpty),
        }.toList()
          ..sort();
        final accounts = <String>{
          _allAccounts,
          ...users.map((u) => u.account.trim()).where((v) => v.isNotEmpty),
        }.toList()
          ..sort();

        if (!buildings.contains(_selectedBuilding)) {
          _selectedBuilding = _allBuildings;
        }
        if (!accounts.contains(_selectedAccount)) {
          _selectedAccount = _allAccounts;
        }

        final filteredUsers = users.where((user) {
          final buildingMatch =
              _selectedBuilding == _allBuildings || user.building == _selectedBuilding;
          final accountMatch =
              _selectedAccount == _allAccounts || user.account == _selectedAccount;
          return buildingMatch && accountMatch;
        }).toList();

        return StreamBuilder<List<TrainingItem>>(
          stream: widget.repository.watchTrainings(),
          builder: (context, trainingSnapshot) {
            final trainings = trainingSnapshot.data ?? const <TrainingItem>[];
            final trainingMap = {for (final item in trainings) item.id: item};

            return StreamBuilder<List<TrainingAssignment>>(
              stream: widget.repository.watchAssignments(),
              builder: (context, assignmentSnapshot) {
                final assignments = assignmentSnapshot.data ?? const <TrainingAssignment>[];
                final filteredUserIds = filteredUsers.map((u) => u.id).toSet();
                final filteredAssignments = assignments
                    .where((assignment) => filteredUserIds.contains(assignment.userId))
                    .toList();

                final assignedTrainingIds = filteredAssignments
                    .map((assignment) => assignment.trainingId)
                    .where(trainingMap.containsKey)
                    .toSet();

                final matrixTrainings = trainings
                    .where((training) => assignedTrainingIds.contains(training.id))
                    .toList()
                  ..sort((a, b) => a.title.compareTo(b.title));

                final assignmentMap = <String, TrainingAssignment>{
                  for (final assignment in filteredAssignments)
                    '${assignment.userId}::${assignment.trainingId}': assignment,
                };

                return Container(
                  color: _page,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Compliance matrix',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: _text,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _FilterDropdown(
                                  label: 'Building',
                                  value: _selectedBuilding,
                                  items: buildings,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedBuilding = value ?? _allBuildings;
                                    });
                                  },
                                ),
                                const SizedBox(width: 12),
                                _FilterDropdown(
                                  label: 'Account',
                                  value: _selectedAccount,
                                  items: accounts,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedAccount = value ?? _allAccounts;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: const [
                                _LegendChip(label: 'Current', color: _green, background: _greenBg),
                                _LegendChip(label: 'Renew within 30 days', color: _yellow, background: _yellowBg),
                                _LegendChip(label: 'Out of compliance', color: _red, background: _redBg),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: filteredUsers.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No users match the selected filters.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _muted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : matrixTrainings.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No assigned trainings found for the selected users yet.',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: _muted,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      : _MatrixTable(
                                          users: filteredUsers,
                                          trainings: matrixTrainings,
                                          assignments: assignmentMap,
                                        ),
                            ),
                          ],
                        ),
                      ),
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
}

class _MatrixTable extends StatelessWidget {
  const _MatrixTable({
    required this.users,
    required this.trainings,
    required this.assignments,
  });

  final List<AppUser> users;
  final List<TrainingItem> trainings;
  final Map<String, TrainingAssignment> assignments;

  static const Color _navy = Color(0xFF011956);
  static const Color _grid = Color(0xFFD9DFEA);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF1A2233);
  static const Color _muted = Color(0xFF697386);

  @override
  Widget build(BuildContext context) {
    final minWidth = 320 + (trainings.length * 140);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _grid),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: minWidth.toDouble()),
              child: SingleChildScrollView(
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: const TableBorder(
                    horizontalInside: BorderSide(color: _grid, width: 1),
                    verticalInside: BorderSide(color: _grid, width: 1),
                  ),
                  columnWidths: {
                    0: const FixedColumnWidth(320),
                    for (int i = 0; i < trainings.length; i++)
                      i + 1: const FixedColumnWidth(140),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: _navy),
                      children: [
                        _headerCell(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'User',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        for (final training in trainings)
                          _headerCell(
                            child: Tooltip(
                              message: training.description,
                              child: Text(
                                training.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    for (final user in users)
                      TableRow(
                        decoration: const BoxDecoration(color: _surface),
                        children: [
                          _bodyCell(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _text,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${user.building} • ${user.account}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: _muted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (final training in trainings)
                            _bodyCell(
                              child: Center(
                                child: _StatusBadge(
                                  assignment: assignments['${user.id}::${training.id}'],
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _headerCell({
    required Widget child,
    Alignment alignment = Alignment.center,
  }) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: alignment,
      child: child,
    );
  }

  static Widget _bodyCell({
    required Widget child,
    Alignment alignment = Alignment.center,
  }) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: alignment,
      child: child,
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  static const Color _navy = Color(0xFF011956);
  static const Color _grid = Color(0xFFD9DFEA);
  static const Color _text = Color(0xFF1A2233);
  static const Color _muted = Color(0xFF697386);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: _grid),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: _navy, width: 1.4),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _muted),
            style: const TextStyle(
              color: _text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            onChanged: onChanged,
            items: items
                .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.close_rounded, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.assignment});

  final TrainingAssignment? assignment;

  static const Color _green = Color(0xFF1E8E3E);
  static const Color _greenBg = Color(0xFFE7F6EC);
  static const Color _yellow = Color(0xFFC58A00);
  static const Color _yellowBg = Color(0xFFFFF4D6);
  static const Color _red = Color(0xFFD93025);
  static const Color _redBg = Color(0xFFFCE8E6);
  static const Color _muted = Color(0xFF697386);

  @override
  Widget build(BuildContext context) {
    if (assignment == null) {
      return const Text(
        '—',
        style: TextStyle(
          color: _muted,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      );
    }

    final now = DateTime.now();
    final dueDate = assignment!.dueAt;
    final daysUntilDue = dueDate.difference(now).inDays;

    late final Color iconColor;
    late final Color backgroundColor;
    late final String tooltip;

    if (dueDate.isBefore(now)) {
      iconColor = _red;
      backgroundColor = _redBg;
      tooltip = 'Out of compliance • due ${DateFormat.yMMMd().format(dueDate)}';
    } else if (daysUntilDue <= 30) {
      iconColor = _yellow;
      backgroundColor = _yellowBg;
      tooltip = 'Renew within 30 days • due ${DateFormat.yMMMd().format(dueDate)}';
    } else {
      iconColor = _green;
      backgroundColor = _greenBg;
      tooltip = 'Current • due ${DateFormat.yMMMd().format(dueDate)}';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: iconColor.withValues(alpha: 0.35)),
        ),
        child: Icon(Icons.close_rounded, size: 18, color: iconColor),
      ),
    );
  }
}
