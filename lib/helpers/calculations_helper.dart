class CalculationsHelper {
  static double calculateAverageGrade(
    List<Map<String, dynamic>> gradedClasses,
  ) {
    final grades =
        gradedClasses
            .map((classData) => classData['finalGrade'] as double)
            .toList();

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

  static double calculateCareerProgress(
    int approvedClasses,
    int totalCareerClasses,
  ) {
    return totalCareerClasses > 0
        ? (approvedClasses / totalCareerClasses) * 100
        : 0.0;
  }

  static List<Map<String, dynamic>> filterGradedClasses(
    List<Map<String, dynamic>> totalClasses,
  ) {
    return totalClasses
        .where(
          (classData) =>
              classData['finalGrade'] != null && classData['finalGrade'] != 0,
        )
        .toList();
  }
}
