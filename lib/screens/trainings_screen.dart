import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/training_item.dart';
import '../repositories/training_repository.dart';
import '../widgets/section_card.dart';

class TrainingsScreen extends StatelessWidget {
  const TrainingsScreen({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TrainingItem>>(
      stream: repository.watchTrainings(),
      builder: (context, snapshot) {
        final trainings = snapshot.data ?? const <TrainingItem>[];
        return SectionCard(
          title: 'Trainings',
          trailing: FilledButton.icon(
            onPressed: () => _showTrainingDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add training'),
          ),
          child: trainings.isEmpty
              ? const Text(
                  'No trainings yet. Create one and optionally upload a linked source document to Firebase Storage.')
              : Column(
                  children: trainings.map((training) {
                    final renewalText = training.renewalMode ==
                            RenewalMode.byCompletion
                        ? 'Renews ${training.renewalIntervalMonths} months after completion'
                        : 'Fixed date • every ${training.renewalIntervalMonths} months';
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(training.description),
                                const SizedBox(height: 8),
                                Text(renewalText),
                                if (training.documentName != null &&
                                    training.documentName!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text('Document: ${training.documentName}'),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showTrainingDialog(context,
                                initialValue: training),
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
  }

  Future<void> _showTrainingDialog(
    BuildContext context, {
    TrainingItem? initialValue,
  }) async {
    final formKey = GlobalKey<FormState>();
    final title = TextEditingController(text: initialValue?.title ?? '');
    final description =
        TextEditingController(text: initialValue?.description ?? '');
    final interval = TextEditingController(
      text: (initialValue?.renewalIntervalMonths ?? 12).toString(),
    );
    final fixedMonth =
        TextEditingController(text: initialValue?.fixedMonth?.toString() ?? '');
    final fixedDay =
        TextEditingController(text: initialValue?.fixedDay?.toString() ?? '');
    var mode = initialValue?.renewalMode ?? RenewalMode.byCompletion;
    PlatformFile? selectedFile;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialValue == null ? 'Add training' : 'Edit training'),
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
                        controller: title,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Required'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: description,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        minLines: 3,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<RenewalMode>(
                        initialValue: mode,
                        decoration:
                            const InputDecoration(labelText: 'Renewal mode'),
                        items: RenewalMode.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => mode = value ?? mode),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: interval,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Renewal interval (months)',
                        ),
                        validator: (value) =>
                            value == null || int.tryParse(value) == null
                                ? 'Enter a number'
                                : null,
                      ),
                      if (mode == RenewalMode.fixedDate) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: fixedMonth,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Fixed month'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: fixedDay,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Fixed day'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonalIcon(
                          onPressed: () async {
                            final result = await FilePicker.platform
                                .pickFiles(withData: true);
                            if (result != null && result.files.isNotEmpty) {
                              setState(() => selectedFile = result.files.first);
                            }
                          },
                          icon: const Icon(Icons.attach_file_outlined),
                          label: Text(
                            selectedFile?.name ??
                                initialValue?.documentName ??
                                'Attach document',
                          ),
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
              await repository.saveTraining(
                (initialValue ?? TrainingItem.empty()).copyWith(
                  title: title.text.trim(),
                  description: description.text.trim(),
                  renewalIntervalMonths: int.parse(interval.text.trim()),
                  renewalMode: mode,
                  fixedMonth: mode == RenewalMode.fixedDate
                      ? int.tryParse(fixedMonth.text.trim())
                      : null,
                  fixedDay: mode == RenewalMode.fixedDate
                      ? int.tryParse(fixedDay.text.trim())
                      : null,
                ),
                file: selectedFile,
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
