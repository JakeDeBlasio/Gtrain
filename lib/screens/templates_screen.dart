import 'package:flutter/material.dart';

import '../models/training_item.dart';
import '../models/training_template.dart';
import '../repositories/training_repository.dart';
import '../widgets/section_card.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TrainingItem>>(
      stream: repository.watchTrainings(),
      builder: (context, trainingSnapshot) {
        final trainings = trainingSnapshot.data ?? const <TrainingItem>[];
        final trainingMap = {for (final item in trainings) item.id: item};
        return StreamBuilder<List<TrainingTemplate>>(
          stream: repository.watchTemplates(),
          builder: (context, templateSnapshot) {
            final templates = templateSnapshot.data ?? const <TrainingTemplate>[];
            return SectionCard(
              title: 'Templates',
              trailing: FilledButton.icon(
                onPressed: trainings.isEmpty
                    ? null
                    : () => _showTemplateDialog(context, trainings: trainings),
                icon: const Icon(Icons.add),
                label: const Text('Add template'),
              ),
              child: templates.isEmpty
                  ? const Text('No templates yet. Build a template to auto-assign trainings when a user is added.')
                  : Column(
                      children: templates.map((template) {
                        final linkedTrainings = template.trainingIds
                            .map((id) => trainingMap[id]?.title ?? id)
                            .join(', ');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blueGrey.shade50),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      template.name,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(template.description),
                                    const SizedBox(height: 8),
                                    Text('Assignments: $linkedTrainings'),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _showTemplateDialog(
                                  context,
                                  trainings: trainings,
                                  initialValue: template,
                                ),
                                icon: const Icon(Icons.edit_outlined),
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

  Future<void> _showTemplateDialog(
    BuildContext context, {
    required List<TrainingItem> trainings,
    TrainingTemplate? initialValue,
  }) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: initialValue?.name ?? '');
    final description = TextEditingController(text: initialValue?.description ?? '');
    final selected = {...?initialValue?.trainingIds};

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialValue == null ? 'Add template' : 'Edit template'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 620,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: name,
                        decoration: const InputDecoration(labelText: 'Template name'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: description,
                        decoration: const InputDecoration(labelText: 'Description'),
                        minLines: 2,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      ...trainings.map(
                        (training) => CheckboxListTile(
                          value: selected.contains(training.id),
                          title: Text(training.title),
                          subtitle: Text(training.description),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selected.add(training.id);
                              } else {
                                selected.remove(training.id);
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
              await repository.saveTemplate(
                (initialValue ?? TrainingTemplate.empty()).copyWith(
                  name: name.text.trim(),
                  description: description.text.trim(),
                  trainingIds: selected.toList(),
                ),
              );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
