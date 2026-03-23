import 'package:cloud_firestore/cloud_firestore.dart';

/// One-time import utility for seeding Firestore with 87 test users
/// This file contains all user data from Users&Roles.csv
/// Remove the import call from main.dart after running once
class FirebaseImportUtils {
  static final List<Map<String, dynamic>> usersData = [
    {'id': 'AANDERSO36', 'name': 'ANDERSON, AIDAN', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'ACASTANED', 'name': 'CASTANEDA, AMAURY', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'ADOSIL', 'name': 'DOSIL, AMANDA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'ADURAN57', 'name': 'DURAN HERNANDEZ, ANGEL', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'ALEYVAMEND', 'name': 'LEYVA MENDOZA, ANTONY', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'ALOPEZ322', 'name': 'LOPEZ, ANDY', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'AMCMILLIAN', 'name': 'MCMILLIAN, ALLEN', 'building': '3411', 'account': '18364', 'role': 'user', 'email': 'allen.mcmillian@geodis.com', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'AREYES030', 'name': 'REYES, ALICIA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'ARODRIG255', 'name': 'RODRIGUEZ MENDEZ, ALEJANDRO', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'AVILLARRE', 'name': 'VILLARREAL, ARMIDA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'BMIRANDA1', 'name': 'MIRANDA, BRYAN', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'BTELLES12', 'name': 'TELLES, BLANCA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'CHERNAND83', 'name': 'ALVAREZ HERNANDEZ, CARMEN', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'CRODRIG28', 'name': 'RODRIGUEZ GUTIERREZ, CINTHYA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'CVERNAZA', 'name': 'VERNAZA, CLAUDIA', 'building': '3411', 'account': '96364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '96364'},
    {'id': 'CWASHINGT7', 'name': 'WASHINGTON, COREY', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'DDORCINE', 'name': 'DORCINE, DELIUS', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'DERRICK71', 'name': 'ROGERS, DERRICK', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'DGILES', 'name': 'GILES, DEREK', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'DGOMEZ17', 'name': 'GOMEZ, DALBERT', 'building': '3411', 'account': '18364', 'role': 'user', 'email': 'dalbert.gomez1@geodis.com', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'DSERRATO1', 'name': 'SERRATO, DANIEL', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'EAMBRIS', 'name': 'AMBRIS DE HURTADO, ELEAZAR', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'EJUAREZ3', 'name': 'JUAREZ, EDUARDO', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'ERELIFORD', 'name': 'RELIFORD, ELISHA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'EREYES65', 'name': 'REYES, ELIZABETH', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'EVINCENT2', 'name': 'VINCENT, EVAN', 'building': '3411', 'account': '18364', 'role': 'user', 'email': 'evan.vincent@geodis.com', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'GAVALOS', 'name': 'AVALOS, GLORIA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'GEDGAR4', 'name': 'GUILLEN, EDGAR', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'GMARVIN', 'name': 'GRIFFIN, MARVIN', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'HCROSSLIN', 'name': 'CROSSLIN, HOLLY', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'HVARGAS1', 'name': 'VARGAS, HECTOR', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'IPERALTA2', 'name': 'PERALTA PASTORA, ILEANA', 'building': '3411', 'account': '96364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '96364'},
    {'id': 'JAGUIRRE10', 'name': 'AGUIRRE, JOSE', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JBOOKER7', 'name': 'BOOKER, JOSEPH', 'building': '3411', 'account': '18364', 'role': 'user', 'email': 'joseph.booker@geodis.com', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JCORONADO1', 'name': 'CORONADO, JOSE', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JDAVALOS2', 'name': 'DAVALOS, JORGE', 'building': '3411', 'account': '18364', 'role': 'user', 'email': 'jorge.davalos@geodis.com', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JDEBLASIO', 'name': 'DEBLASIO, JAKE', 'building': '3411', 'account': '18364', 'role': 'admin', 'email': 'jake.deblasio@geodis.com', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JELDER2', 'name': 'ELDER, JOSHUA', 'building': '3411', 'account': '18364', 'role': 'user', 'email': 'joshua.elder@geodis.com', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JGANDARA', 'name': 'GANDARA, JORGE', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JHOLMES59', 'name': 'HOLMES, JAMES', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JLOBATO', 'name': 'LOBATO, JOSE', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JLOVE36', 'name': 'LOVE, JAMAIL', 'building': '3411', 'account': '18364', 'role': 'user', 'email': 'jamail.love@geodis.com', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JRUIZ33', 'name': 'RUIZ, JONATHAN', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JSALINAS94', 'name': 'SALINAS, JUDYTH', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JSANDOVAL3', 'name': 'SANDOVAL-MENDEZ, JACQUELINE', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JSTRICK', 'name': 'STRICKLAND, JAMES', 'building': '3411', 'account': '18364', 'role': 'user', 'email': 'james.strickland2@geodis.com', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'JVARGAS45', 'name': 'VARGAS, JANETH', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'KALLEN15', 'name': 'ALLEN, KARL', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'KHERNANDE9', 'name': 'HERNANDEZ, KATHY', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'KRUEDA2', 'name': 'RUEDA HERNANDEZ, KARLA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'KSIGUEN002', 'name': 'SIGUENZA, KETTY', 'building': '3411', 'account': '18364', 'role': 'user', 'email': 'ketty.siguenza@geodis.com', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'LFUENTEALV', 'name': 'FUENTE ALVARADO, LUIS', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'LGAMEZ', 'name': 'GAMEZ, LEONARDO', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'LRODRIGU58', 'name': 'RODRIGUEZ OSPINA, LUZ', 'building': '3411', 'account': '96364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '96364'},
    {'id': 'MARGUETA4', 'name': 'ARGUETA, MARIA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'MBECERRAPR', 'name': 'BECERRA PRIETO, MA GUADALUPE', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'MCENTENO4', 'name': 'HERNANDEZ CENTENO, MARIA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'MHERNAN707', 'name': 'HERNANDEZ, MELANIE', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'MMADRIGA2', 'name': 'GUILLEN, MARIA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'MVALLEJO9', 'name': 'VAZQUEZ, MARIA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'NBRYANT51', 'name': 'BRYANT, NEVOS', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'NDELGADILL', 'name': 'DELGADILLO SANCHEZ, NASLIN', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'NGONZALE20', 'name': 'GONZALEZ, NAHIROBY', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'NMANCILLAS', 'name': 'MANCILLAS, NAYARA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'OBARAJAS2', 'name': 'BARAJAS, OSCAR', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'PACUNA1', 'name': 'ACUNA, PAOLA', 'building': '3411', 'account': '96364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '96364'},
    {'id': 'PGONZALES', 'name': 'GONZALEZ, PATRICIA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'PHERNAND55', 'name': 'HERNANDEZ SOTO, PAVEL', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'PREEVE', 'name': 'REEVES, PAIGE', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'PSILVA2', 'name': 'SILVA CISNEROS, PAOLA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'PVIDALES1', 'name': 'VIDALES, PAOLA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'PWHITE12', 'name': 'WHITE, PERRISON', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'RROQUE1', 'name': 'ROQUE, RICHARD', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'RRUIZ21', 'name': 'RUIZ MEZA, REY', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'SALVARADO2', 'name': 'ALVARADO, SINDY', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'SAPOSTALO', 'name': 'APOSTALO, SCOTT', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'SCAVAN', 'name': 'CAVAN, SHAWN', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'SGUILLEN3', 'name': 'GUILLEN MADRIGAL, STEPHANIE', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'SGUTIERREZ', 'name': 'GUTIERREZ, SERGIO', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'TLUAN', 'name': 'LUAN, TUAN', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'VCAST01', 'name': 'CASTANEDA, VICTOR', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'VHERNAND17', 'name': 'HERNANDEZ, VICTOR', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'VHERRERA', 'name': 'HERRERA-ZARAGOZA, VANESSA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'VROSASRODR', 'name': 'ROSAS RODRIGUEZ, VICTOR', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'WRODRIGU8', 'name': 'SIGUENZA RODRIGUEZ, WENDY GABRIELA', 'building': '3411', 'account': '96364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '96364'},
    {'id': 'YMOORE51', 'name': 'MOORE, YUSEF', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
    {'id': 'YRINCON3', 'name': 'RINCON, YASMIRA', 'building': '3411', 'account': '18364', 'role': 'teammate', 'templateIds': [], 'defaultBuilding': '3411', 'defaultAccount': '18364'},
  ];

  /// Import all 87 users to Firestore in batches
  static Future<void> importAllUsers() async {
    final firestore = FirebaseFirestore.instance;
    
    print('\n🚀 Starting import of ${usersData.length} users to Firestore...\n');
    
    int successCount = 0;
    
    // Use batches for efficiency (Firestore batch write limit is 500)
    const batchSize = 100;
    
    for (int i = 0; i < usersData.length; i += batchSize) {
      final batch = firestore.batch();
      final batchUsers = usersData.sublist(
        i,
        i + batchSize > usersData.length ? usersData.length : i + batchSize,
      );
      
      for (final user in batchUsers) {
        final docRef = firestore.collection('users').doc(user['id']);
        batch.set(docRef, {
          ...user,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      try {
        await batch.commit();
        successCount += batchUsers.length;
        print('✓ Batch ${(i ~/ batchSize) + 1}: ${batchUsers.length} users imported');
      } catch (e) {
        print('✗ Batch ${(i ~/ batchSize) + 1} failed: $e');
        rethrow;
      }
    }
    
    print('\n════════════════════════════════════════════════════');
    print('✅ IMPORT COMPLETE!');
    print('   Total users imported: $successCount');
    print('════════════════════════════════════════════════════\n');
  }
}
