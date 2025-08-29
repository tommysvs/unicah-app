class CalculationsHelper {
  static double calculateAverageGrade(
    List<Map<String, dynamic>> gradedClasses,
  ) {
    final grades =
        gradedClasses.map((classData) {
          final grade = classData['finalGrade'];
          if (grade is int) {
            return grade.toDouble();
          } else if (grade is double) {
            return grade;
          } else if (grade is num) {
            return grade.toDouble();
          }
          return 0.0;
        }).toList();

    return grades.isNotEmpty
        ? (grades.reduce((a, b) => a + b) / grades.length)
        : 0.0;
  }

  static int calculateApprovedClasses(
    List<Map<String, dynamic>> gradedClasses,
  ) {
    return gradedClasses
        .where((classData) => classData['status'] == 'Aprobada')
        .length;
  }

  static int totalCareerClasses = 60;

  static double calculateCareerProgress(int approvedClasses) {
    return totalCareerClasses > 0
        ? (approvedClasses / totalCareerClasses) * 100
        : 0.0;
  }

  static List<Map<String, dynamic>> filterGradedClasses(
    List<Map<String, dynamic>> totalClasses,
  ) {
    return totalClasses.where((classData) {
      final grade = classData['finalGrade'];
      return grade != null &&
          ((grade is num && grade != 0) ||
              (grade is String && grade.isNotEmpty && grade != '0'));
    }).toList();
  }
}
