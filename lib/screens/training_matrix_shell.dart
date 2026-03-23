import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/app_user.dart';
import '../models/user_role.dart';
import '../repositories/training_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'compliance_matrix_screen.dart';
import 'dashboard_screen.dart';
import 'templates_screen.dart';
import 'trainings_screen.dart';
import 'users_screen.dart';

class TrainingMatrixShell extends StatefulWidget {
  TrainingMatrixShell({
    super.key,
    required this.repository,
    AuthService? authService,
  }) : authService = authService ?? AuthService();

  final TrainingRepository repository;
  final AuthService authService;

  @override
  State<TrainingMatrixShell> createState() => _TrainingMatrixShellState();
}

class _TrainingMatrixShellState extends State<TrainingMatrixShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final userRole = widget.authService.currentUserRole ?? UserRole.user;
    
    // Define all screens (indices 0-4 reserved for navigation order)
    final allScreens = [
      DashboardScreen(
        repository: widget.repository,
        onNavigate: (index) => setState(() => _index = index),
      ),
      ComplianceMatrixScreen(repository: widget.repository),
      UsersScreen(
        repository: widget.repository,
        authService: widget.authService,
      ),
      TrainingsScreen(repository: widget.repository),
      TemplatesScreen(repository: widget.repository),
    ];

    // Filter screens based on user role
    final screens = <Widget>[];
    final navigationPages = <NavigationPage>[];
    
    for (int i = 0; i < allScreens.length; i++) {
      final page = NavigationPage.values[i];
      if (userRole.canAccess(page)) {
        screens.add(allScreens[i]);
        navigationPages.add(page);
      }
    }

    // Ensure index is valid
    if (_index >= screens.length) {
      _index = 0;
    }

    // Build destinations based on accessible pages
    final destinations = navigationPages
        .map(
          (page) => NavigationDestination(
            icon: _getPageIcon(page),
            label: page.label,
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 88,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'design/gtrain_logo.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'G-Train',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (userRole != UserRole.teammate)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: FilledButton(
                          onPressed: () => _showUploadCompletedTrainingDialog(context),
                          child: const Text('Upload Completed Training'),
                        ),
                      ),
                    _buildUserMenu(context),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [],
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
                  padding: const EdgeInsets.all(12)
                ),
                destinations: navigationPages
                    .map(
                      (page) => NavigationRailDestination(
                        icon: _getPageIcon(page),
                        label: Text(page.label),
                      ),
                    )
                    .toList(),
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

  Icon _getPageIcon(NavigationPage page) {
    return switch (page) {
      NavigationPage.dashboard => const Icon(Icons.dashboard_outlined),
      NavigationPage.compliance => const Icon(Icons.grid_view_rounded),
      NavigationPage.users => const Icon(Icons.people_alt_outlined),
      NavigationPage.trainings => const Icon(Icons.menu_book_outlined),
      NavigationPage.templates => const Icon(Icons.auto_awesome_motion_outlined),
      _ => const Icon(Icons.help_outline),
    };
  }

  Widget _buildUserMenu(BuildContext context) {
    final currentUser = widget.authService.currentUser;
    final userRole = widget.authService.currentUserRole ?? UserRole.user;

    return StreamBuilder<List<AppUser>>(
      stream: widget.repository.watchUsers(),
      builder: (context, snapshot) {
        final allUsers = snapshot.data ?? const <AppUser>[];
        
        // Get unique buildings and accounts from all users
        final buildings = <String>{
          if (currentUser?.defaultBuilding != null) currentUser!.defaultBuilding!,
          ...allUsers.map((u) => u.building).where((b) => b.isNotEmpty),
        }.toList()
            ..sort();
        
        final accounts = <String>{
          if (currentUser?.defaultAccount != null) currentUser!.defaultAccount!,
          ...allUsers.map((u) => u.account).where((a) => a.isNotEmpty),
        }.toList()
            ..sort();

        return PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          offset: const Offset(0, 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.brandBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.brandBlue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: 18, color: AppTheme.brandBlue),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentUser?.name ?? 'User',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userRole.displayName,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.expand_more, size: 18),
              ],
            ),
          ),
          onSelected: (value) {
            // Menu selections are handled internally
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Default Location',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 200,
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return DropdownButtonFormField<String>(
                            value: currentUser?.defaultBuilding ?? '',
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: buildings
                                .map((b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(b),
                                ))
                                .toList(),
                            onChanged: (value) async {
                              if (value != null) {
                                await widget.authService.updateUserDefaults(
                                  building: value,
                                  account: currentUser?.defaultAccount ?? '',
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuItem<String>(
              enabled: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Default Account',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 200,
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return DropdownButtonFormField<String>(
                            value: currentUser?.defaultAccount ?? '',
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: accounts
                                .map((a) => DropdownMenuItem(
                                  value: a,
                                  child: Text(a),
                                ))
                                .toList(),
                            onChanged: (value) async {
                              if (value != null) {
                                await widget.authService.updateUserDefaults(
                                  building: currentUser?.defaultBuilding ?? '',
                                  account: value,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUploadCompletedTrainingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CompletedTrainingUploadDialog(
        repository: widget.repository,
      ),
    );
  }
}

class _CompletedTrainingUploadDialog extends StatefulWidget {
  const _CompletedTrainingUploadDialog({
    required this.repository,
  });

  final TrainingRepository repository;

  @override
  State<_CompletedTrainingUploadDialog> createState() => _CompletedTrainingUploadDialogState();
}

class _CompletedTrainingUploadDialogState extends State<_CompletedTrainingUploadDialog> {
  PlatformFile? selectedFile;
  final selectedUserIds = <String>{};
  DateTime completionDate = DateTime.now();
  TimeOfDay completionTime = TimeOfDay.now();
  final searchController = TextEditingController();
  String trainingTitle = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 1000,
        height: 600,
        child: Row(
          children: [
            // Left side - Document Upload
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Document',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Training Title',
                        hintText: 'e.g., Annual Safety Training',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => trainingTitle = value),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: AppTheme.brandBlue,
                            ),
                            const SizedBox(height: 12),
                            if (selectedFile == null)
                              Column(
                                children: [
                                  const Text(
                                    'Click to upload document',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'PDF, Word, or Excel',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green, size: 40),
                                  const SizedBox(height: 8),
                                  Text(selectedFile!.name),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => setState(() => selectedFile = null),
                                    child: const Text(
                                      'Remove',
                                      style: TextStyle(
                                        color: Colors.red,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Completion Date & Time',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () => _selectDate(),
                            child: Text('Date: ${completionDate.toLocal().toString().split(' ')[0]}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () => _selectTime(),
                            child: Text('Time: ${completionTime.format(context)}'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Right side - User Selection
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Users',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search users',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: StreamBuilder<List<AppUser>>(
                        stream: widget.repository.watchUsers(),
                        builder: (context, snapshot) {
                          final allUsers = snapshot.data ?? const <AppUser>[];
                          final searchTerm = searchController.text.toLowerCase();
                          final filteredUsers = allUsers
                              .where((u) =>
                              u.name.toLowerCase().contains(searchTerm) ||
                              u.building.toLowerCase().contains(searchTerm))
                              .toList();

                          return ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              final isSelected = selectedUserIds.contains(user.id);
                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedUserIds.add(user.id);
                                    } else {
                                      selectedUserIds.remove(user.id);
                                    }
                                  });
                                },
                                title: Text(user.name),
                                subtitle: Text('${user.building} • ${user.account}'),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: selectedFile != null &&
                              trainingTitle.isNotEmpty &&
                              selectedUserIds.isNotEmpty
                              ? () => _submitUpload()
                              : null,
                          child: const Text('Upload & Complete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );

    if (result != null) {
      setState(() => selectedFile = result.files.first);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: completionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => completionDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: completionTime,
    );
    if (picked != null) {
      setState(() => completionTime = picked);
    }
  }

  Future<void> _submitUpload() async {
    if (selectedFile == null || trainingTitle.isEmpty || selectedUserIds.isEmpty) {
      return;
    }

    try {
      final file = selectedFile!; // Non-null assertion since we checked above
      
      // Combine date and time
      final completionDateTime = DateTime(
        completionDate.year,
        completionDate.month,
        completionDate.day,
        completionTime.hour,
        completionTime.minute,
      );

      // Mark training as completed for all selected users
      await widget.repository.recordTrainingCompletion(
        trainingTitle: trainingTitle,
        userIds: selectedUserIds.toList(),
        completedAt: completionDateTime,
        file: file,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Training completion recorded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
