import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/training_template.dart';
import '../repositories/training_repository.dart';
import '../widgets/section_card.dart';
import 'user_detail_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: repository.watchUsers(),
      builder: (context, userSnapshot) {
        final users = userSnapshot.data ?? const <AppUser>[];
        return StreamBuilder<List<TrainingTemplate>>(
          stream: repository.watchTemplates(),
          builder: (context, templateSnapshot) {
            final templates = templateSnapshot.data ?? const <TrainingTemplate>[];
            return SectionCard(
              title: 'Users',
              trailing: FilledButton.icon(
                onPressed: () => _showUserDialog(context, templates: templates),
                icon: const Icon(Icons.add),
                label: const Text('Add user'),
              ),
              child: users.isEmpty
                  ? const Text('No users yet. Add a user and attach templates to auto-assign their required trainings.')
                  : Column(
                      children: users.map((user) {
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
                                    Text(
                                      user.name,
                                      style: Theme.of(context).textTheme.titleMedium,
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
                                        repository: repository,
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
                await repository.saveUser(
                  (initialValue ?? AppUser.empty()).copyWith(
                    name: name.text.trim(),
                    building: building.text.trim(),
                    account: account.text.trim(),
                    email: email.text.trim(),
                    templateIds: selectedTemplateIds.toList(),
                  ),
                );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
