import 'dart:io';
import 'package:csv/csv.dart';

// Map role string from CSV to Firestore role value
String mapRoleToFirestore(String csvRole) {
  final lower = csvRole.trim().toLowerCase();
  
  if (lower == 'admin') return 'admin';
  if (lower == 'user') return 'user';
  if (lower == 'teammate') return 'teammate';
  
  return 'user'; // Default
}

Future<void> main() async {
  // Read CSV file
  final file = File('Users&Roles.csv');
  if (!file.existsSync()) {
    print('❌ Error: Users&Roles.csv not found in project root');
    exit(1);
  }
  
  final csv = file.readAsStringSync();
  final rows = CsvToListConverter().convert(csv);
  
  // Skip header row
  final dataRows = rows.skip(1).toList();
  
  // Build name to user ID map for supervisor lookups
  final nameToUserId = <String, String>{};
  for (final row in dataRows) {
    final userId = row[2].toString().trim();
    final employeeName = row[4].toString().trim();
    nameToUserId[employeeName] = userId;
  }
  
  print('📊 Preparing to import ${dataRows.length} users to Firebase...\n');
  
  // Generate Firestore import JSON
  final firebaseImportData = <Map<String, dynamic>>[];
  
  for (final row in dataRows) {
    try {
      // CSV columns: BUILDING, ACCOUNT, USER_ID, EMPLOYEE_NUMBER, EMPLOYEE_NAME, SUPERVISOR_FULL_NAME, JOB_TITLE, Email, Role
      final building = row[0].toString().trim();
      final account = row[1].toString().trim();
      final userId = row[2].toString().trim();
      final employeeName = row[4].toString().trim();
      final supervisorName = row[5].toString().trim();
      final email = row[7].toString().trim();
      final csvRole = row[8].toString().trim();
      
      // Find supervisor ID
      String? supervisorId;
      if (supervisorName.isNotEmpty) {
        supervisorId = nameToUserId[supervisorName];
      }
      
      // Map role
      final role = mapRoleToFirestore(csvRole);
      
      // Create user data
      final userData = <String, dynamic>{
        'id': userId,
        'name': employeeName,
        'building': building,
        'account': account,
        'templateIds': [],
        'role': role,
        'defaultBuilding': building,
        'defaultAccount': account,
      };
      
      if (email.isNotEmpty) {
        userData['email'] = email;
      }
      
      if (supervisorId != null) {
        userData['supervisorId'] = supervisorId;
      }
      
      firebaseImportData.add({
        'id': userId,
        'data': userData,
      });
      
      print('✓ $employeeName ($userId) - Role: $role');
    } catch (e) {
      print('✗ Error processing row: $e');
    }
  }
  
  // Create import instructions
  final instructions = '''
📋 FIREBASE IMPORT INSTRUCTIONS
═══════════════════════════════════════════════════════════

✅ Data prepared: ${firebaseImportData.length} users ready to import

TO IMPORT TO FIREBASE:

Option 1: Use Firebase Console (Manual)
─────────────────────────────────────
1. Go to Firebase Console → Firestore Database
2. For each user, click "Add collection" → name it "users"
3. Add a document with ID matching USER_ID
4. Copy the fields from the data below

Option 2: Use Firebase CLI (Recommended)
──────────────────────────────────────
1. Install Firebase CLI: npm install -g firebase-tools
2. Create import_data.json from this data
3. Run: firebase firestore:imprt import_data.json --collection-path=users

Option 3: Use Admin SDK in Flutter
───────────────────────────────────
Add this code to your app's initialization:

```dart
Future<void> importUsersToFirebase() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();
  
  final usersData = ${firebaseImportData.toString()};
  
  for (final user in usersData) {
    final docRef = firestore.collection('users').doc(user['id']);
    batch.set(docRef, {
      ...user['data'],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  await batch.commit();
  print('✓ Imported \${usersData.length} users');
}
```

USER DATA FOR IMPORT:
═════════════════════════════════════════════════════════════
''';
  
  print('\n$instructions');
  
  // Save import data to JSON file
  final jsonOutput = StringBuffer();
  jsonOutput.writeln('[');
  for (int i = 0; i < firebaseImportData.length; i++) {
    final user = firebaseImportData[i];
    jsonOutput.write('  {"userId": "${user['id']}", "data": ${user['data']}}');
    if (i < firebaseImportData.length - 1) {
      jsonOutput.write(',');
    }
    jsonOutput.writeln();
  }
  jsonOutput.writeln(']');
  
  final outputFile = File('users_import_data.json');
  outputFile.writeAsStringSync(jsonOutput.toString());
  print('📁 JSON data saved to: users_import_data.json\n');
  
  print('════════════════════════════════════════════════════════');
  print('✅ Import preparation complete!');
  print('════════════════════════════════════════════════════════');
}
