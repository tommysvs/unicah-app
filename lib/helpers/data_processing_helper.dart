import 'package:cloud_firestore/cloud_firestore.dart';

class DataProcessingHelper {
  static List<Map<String, dynamic>> processSnapshotData(
    QuerySnapshot snapshot,
  ) {
    return snapshot.docs.expand((doc) {
      final data = doc.data() as Map<String, dynamic>;

      final classList = data['classes'] as List<dynamic>? ?? [];
      return classList.whereType<Map<String, dynamic>>().map((classData) {
        return {
          'className': classData['className'] ?? 'Sin nombre',
          'finalGrade': classData['finalGrade'] ?? 0,
          'credits': classData['credits'] ?? 0,
          'status': classData['status'] ?? 'Sin estado',
          'dependencies': List<String>.from(classData['dependencies'] ?? []),
        };
      }).toList();
    }).toList();
  }
}
