import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'repositories/training_repository.dart';
import 'screens/training_matrix_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GTrainApp());
}

class GTrainApp extends StatelessWidget {
  const GTrainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Training Matrix',
      theme: AppTheme.light,
      home: TrainingMatrixShell(
        repository: TrainingRepository(),
      ),
    );
  }
}
