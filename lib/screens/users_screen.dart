import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/training_template.dart';
import '../models/user_role.dart';
import '../repositories/training_repository.dart';
import '../services/auth_service.dart';
import '../widgets/section_card.dart';
import 'user_detail_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({
    super.key,
    required this.repository,
    this.authService,
  });

  final TrainingRepository repository;
  final AuthService? authService;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _searchTerm = '';
  String? _selectedBuilding;
  String? _selectedAccount;

  bool get _isAdmin => (widget.authService ?? AuthService()).isAdmin;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: widget.repository.watchUsers(),
      builder: (context, userSnapshot) {
        final users = userSnapshot.data ?? const <AppUser>[];
        return StreamBuilder<List<TrainingTemplate>>(
          stream: widget.repository.watchTemplates(),
          builder: (context, templateSnapshot) {
            final templates = templateSnapshot.data ?? const <TrainingTemplate>[];

            // Get unique buildings and accounts for filter dropdowns
            final buildings = <String>{
              ...users.map((u) => u.building).where((b) => b.isNotEmpty),
            }.toList()
              ..sort();

            final accounts = <String>{
              ...users.map((u) => u.account).where((a) => a.isNotEmpty),
            }.toList()
              ..sort();

            // Filter users based on search and filters
            final filteredUsers = users.where((user) {
              final matchesSearch = _searchTerm.isEmpty ||
                  user.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                  user.email.toLowerCase().contains(_searchTerm.toLowerCase());
              final matchesBuilding = _selectedBuilding == null || user.building == _selectedBuilding;
              final matchesAccount = _selectedAccount == null || user.account == _selectedAccount;
              return matchesSearch && matchesBuilding && matchesAccount;
            }).toList();

            return SectionCard(
              title: 'Users',
              trailing: _isAdmin
                  ? FilledButton.icon(
                      onPressed: () => _showUserDialog(context, templates: templates),
                      icon: const Icon(Icons.add),
                      label: const Text('Add user'),
                    )
                  : null,
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
                              hintText: 'Search by name or email...',
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
                    // User list
                    if (userSnapshot.connectionState == ConnectionState.waiting && users.isEmpty)
                      const Expanded(
                        child: Center(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    else if (filteredUsers.isEmpty && users.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text('No users yet. Add a user and attach templates to auto-assign their required trainings.'),
                        ),
                      )
                    else if (filteredUsers.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text('No users match your search and filter criteria.'),
                        ),
                      )
                    else
                      Expanded(
                        child: RawScrollbar(
                          thumbVisibility: true,
                          thickness: 8,
                          radius: const Radius.circular(4),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: filteredUsers.map((user) {
                                final attachedTemplates = templates
                                    .where((template) => user.templateIds.contains(template.id))
                                    .map((template) => template.name)
                                    .join(', ');
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
                                            Row(
                                              children: [
                                                Text(
                                                  user.name,
                                                  style: Theme.of(context).textTheme.titleMedium,
                                                ),
                                                const SizedBox(width: 12),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _getRoleColor(user.role).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    user.role.displayName,
                                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                      color: _getRoleColor(user.role),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text('${user.building} • ${user.account}'),
                                            if (attachedTemplates.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text('Templates: $attachedTemplates'),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (_isAdmin)
                                        IconButton(
                                          tooltip: 'Edit user',
                                          onPressed: () => _showUserDialog(
                                            context,
                                            templates: templates,
                                            initialValue: user,
                                          ),
                                          icon: const Icon(Icons.edit_outlined),
                                        ),
                                      FilledButton.tonal(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) => UserDetailScreen(
                                                repository: widget.repository,
                                                user: user,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Open matrix'),
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
  }

  Future<void> _showUserDialog(
    BuildContext context, {
    required List<TrainingTemplate> templates,
    AppUser? initialValue,
  }) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: initialValue?.name ?? '');
    final building = TextEditingController(text: initialValue?.building ?? '');
    final account = TextEditingController(text: initialValue?.account ?? '');
    final email = TextEditingController(text: initialValue?.email ?? '');
    final selectedTemplateIds = {...?initialValue?.templateIds};
    var selectedRole = initialValue?.role ?? UserRole.user;
    var selectedSupervisorId = initialValue?.supervisorId ?? '';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(initialValue == null ? 'Add user' : 'Edit user'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 560,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: name,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: building,
                          decoration: const InputDecoration(labelText: 'Building'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: account,
                          decoration: const InputDecoration(labelText: 'Account'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: email,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<List<AppUser>>(
                          stream: widget.repository.watchUsers(),
                          builder: (context, snapshot) {
                            final allUsers = snapshot.data ?? const <AppUser>[];
                            final supervisors = allUsers
                                .where((u) => u.id != initialValue?.id)
                                .toList();
                            return DropdownButtonFormField<String>(
                              value: selectedSupervisorId.isEmpty ? null : selectedSupervisorId,
                              decoration: const InputDecoration(labelText: 'Supervisor'),
                              items: [
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('None'),
                                ),
                                ...supervisors
                                    .map((supervisor) => DropdownMenuItem(
                                      value: supervisor.id,
                                      child: Text(supervisor.name),
                                    ))
                                    .toList(),
                              ],
                              onChanged: (value) {
                                setState(() => selectedSupervisorId = value ?? '');
                              },
                            );
                          },
                        ),
                        if (_isAdmin) ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Role',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<UserRole>(
                            value: selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'User Role',
                            ),
                            items: UserRole.values
                                .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role.displayName),
                                ))
                                .toList(),
                            onChanged: (role) {
                              if (role != null) {
                                setState(() => selectedRole = role);
                              }
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Apply templates',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...templates.map(
                          (template) => CheckboxListTile(
                            value: selectedTemplateIds.contains(template.id),
                            title: Text(template.name),
                            subtitle: Text(template.description),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedTemplateIds.add(template.id);
                                } else {
                                  selectedTemplateIds.remove(template.id);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final user = (initialValue ?? AppUser.empty()).copyWith(
                  name: name.text.trim(),
                  building: building.text.trim(),
                  account: account.text.trim(),
                  email: email.text.trim(),
                  templateIds: selectedTemplateIds.toList(),
                  role: selectedRole,
                  supervisorId: selectedSupervisorId.isEmpty ? null : selectedSupervisorId,
                );
                await widget.repository.saveUser(user);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Color _getRoleColor(UserRole role) {
    return switch (role) {
      UserRole.admin => const Color(0xFFE74C3C),
      UserRole.trainingManager => const Color(0xFFF39C12),
      UserRole.user => const Color(0xFF3498DB),
      UserRole.teammate => const Color(0xFF9B59B6),
    };
  }
}
