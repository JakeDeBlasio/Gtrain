import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_user.dart';
import '../models/training_assignment.dart';
import '../models/training_item.dart';
import '../models/training_template.dart';

class TrainingRepository {
  TrainingRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _trainings =>
      _firestore.collection('trainings');
  CollectionReference<Map<String, dynamic>> get _templates =>
      _firestore.collection('templates');
  CollectionReference<Map<String, dynamic>> get _assignments =>
      _firestore.collection('assignments');

  Stream<List<AppUser>> watchUsers() {
    return _users.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => AppUser.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<TrainingItem>> watchTrainings() {
    return _trainings.orderBy('title').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => TrainingItem.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<TrainingTemplate>> watchTemplates() {
    return _templates.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => TrainingTemplate.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<TrainingAssignment>> watchAssignmentsForUser(String userId) {
    return _assignments.where('userId', isEqualTo: userId).snapshots().map(
          (snapshot) {
            final items = snapshot.docs
                .map((doc) => TrainingAssignment.fromMap(doc.id, doc.data()))
                .toList();
            items.sort((a, b) => a.dueAt.compareTo(b.dueAt));
            return items;
          },
        );
  }

  Stream<List<TrainingAssignment>> watchAssignments() {
    return _assignments.orderBy('dueAt').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => TrainingAssignment.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<TrainingAssignment>> watchUpcomingAssignments() {
    return _assignments.orderBy('dueAt').limit(12).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => TrainingAssignment.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> saveUser(AppUser user) async {
    final isNew = user.id.isEmpty;
    final docRef = isNew ? _users.doc() : _users.doc(user.id);

    final previousTemplateIds = <String>{};
    if (!isNew) {
      final existing = await docRef.get();
      if (existing.exists) {
        previousTemplateIds
            .addAll(List<String>.from(existing.data()?['templateIds'] ?? const []));
      }
    }

    await docRef.set(
      {
        ...user.copyWith(id: docRef.id).toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (isNew) 'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    final addedTemplates = user.templateIds.toSet().difference(previousTemplateIds);
    for (final templateId in addedTemplates) {
      await applyTemplateToUser(docRef.id, templateId);
    }
  }

  Future<void> saveTemplate(TrainingTemplate template) async {
    final isNew = template.id.isEmpty;
    final docRef = isNew ? _templates.doc() : _templates.doc(template.id);
    await docRef.set(
      {
        ...template.copyWith(id: docRef.id).toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (isNew) 'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> saveTraining(TrainingItem training, {PlatformFile? file}) async {
    final isNew = training.id.isEmpty;
    final docRef = isNew ? _trainings.doc() : _trainings.doc(training.id);

    String? documentName = training.documentName;
    String? documentUrl = training.documentUrl;
    String? documentPath = training.documentPath;

    if (file != null) {
      final upload = await uploadDocument(trainingId: docRef.id, file: file);
      documentName = upload.$1;
      documentUrl = upload.$2;
      documentPath = upload.$3;
    }

    await docRef.set(
      {
        ...training
            .copyWith(
              id: docRef.id,
              documentName: documentName,
              documentUrl: documentUrl,
              documentPath: documentPath,
            )
            .toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (isNew) 'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<(String, String, String)> uploadDocument({
    required String trainingId,
    required PlatformFile file,
  }) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('File bytes were not available. Pick again with data enabled.');
    }

    final safeFileName = file.name.replaceAll(RegExp(r'\s+'), '_');
    final ref = _storage.ref(
      'training_documents/$trainingId/${DateTime.now().millisecondsSinceEpoch}_$safeFileName',
    );
    final metadata = SettableMetadata(
      contentType: _contentTypeFor(file.name),
    );
    await ref.putData(Uint8List.fromList(bytes), metadata);
    final url = await ref.getDownloadURL();
    return (file.name, url, ref.fullPath);
  }

  Future<void> applyTemplateToUser(String userId, String templateId) async {
    final templateSnapshot = await _templates.doc(templateId).get();
    if (!templateSnapshot.exists) return;

    final template =
        TrainingTemplate.fromMap(templateSnapshot.id, templateSnapshot.data()!);
    final existingAssignments = await _assignments
        .where('userId', isEqualTo: userId)
        .get();
    final existingTrainingIds = existingAssignments.docs
        .map((doc) => (doc.data()['trainingId'] ?? '') as String)
        .toSet();

    for (final trainingId in template.trainingIds) {
      if (existingTrainingIds.contains(trainingId)) continue;
      await assignTrainingToUser(
        userId: userId,
        trainingId: trainingId,
        source: 'template',
        templateId: template.id,
      );
    }
  }

  Future<void> assignTrainingToUser({
    required String userId,
    required String trainingId,
    String source = 'manual',
    String? templateId,
  }) async {
    final trainingSnapshot = await _trainings.doc(trainingId).get();
    if (!trainingSnapshot.exists) return;
    final training =
        TrainingItem.fromMap(trainingSnapshot.id, trainingSnapshot.data()!);

    final now = DateTime.now();
    await _assignments.doc().set({
      'userId': userId,
      'trainingId': trainingId,
      'source': source,
      'templateId': templateId,
      'assignedAt': now,
      'dueAt': computeNextDueDate(training, referenceDate: now),
      'completedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAssignmentCompleted({
    required TrainingAssignment assignment,
    required TrainingItem training,
    DateTime? completedAt,
  }) async {
    final completionDate = completedAt ?? DateTime.now();
    await _assignments.doc(assignment.id).set(
      {
        'completedAt': completionDate,
        'dueAt': computeNextDueDate(training, referenceDate: completionDate),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteUser(String id) async {
    final assignments = await _assignments.where('userId', isEqualTo: id).get();
    final batch = _firestore.batch();
    for (final doc in assignments.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_users.doc(id));
    await batch.commit();
  }

  Future<void> deleteTraining(String id) async {
    final doc = await _trainings.doc(id).get();
    final path = doc.data()?['documentPath'] as String?;
    if (path != null && path.isNotEmpty) {
      await _storage.ref(path).delete().catchError((_) {});
    }
    await _trainings.doc(id).delete();
  }

  Future<void> deleteTemplate(String id) async {
    await _templates.doc(id).delete();
  }

  DateTime computeNextDueDate(
    TrainingItem training, {
    required DateTime referenceDate,
  }) {
    if (training.renewalMode == RenewalMode.fixedDate &&
        training.fixedMonth != null &&
        training.fixedDay != null) {
      final thisYear = DateTime(
        referenceDate.year,
        training.fixedMonth!,
        training.fixedDay!,
      );
      if (!thisYear.isBefore(referenceDate)) {
        return thisYear;
      }
      return DateTime(
        referenceDate.year + 1,
        training.fixedMonth!,
        training.fixedDay!,
      );
    }

    return DateTime(
      referenceDate.year,
      referenceDate.month + training.renewalIntervalMonths,
      referenceDate.day,
    );
  }

  String _contentTypeFor(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.doc')) return 'application/msword';
    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lower.endsWith('.xls')) return 'application/vnd.ms-excel';
    if (lower.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    return 'application/octet-stream';
  }
}
