import 'package:flutter/material.dart';
import 'class_card.dart';

class PeriodSection extends StatelessWidget {
  final String romanNumber;
  final List<Map<String, dynamic>> classes;
  final String? highlightedClassCode;
  final Set<String> relatedClasses;
  final Function(String) onClassTap;
  final Function(Map<String, dynamic>) onEditClass;

  const PeriodSection({
    super.key,
    required this.romanNumber,
    required this.classes,
    this.highlightedClassCode,
    required this.relatedClasses,
    required this.onClassTap,
    required this.onEditClass,
  });

  double? _convertToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(85, 219, 219, 219),
            Color.fromARGB(0, 216, 225, 255),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text(
                romanNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Wrap(
                spacing: 1.5,
                runSpacing: 1.5,
                children:
                    classes.map((classData) {
                      final isHighlighted =
                          highlightedClassCode == classData['classCode'];
                      final isRelated = relatedClasses.contains(
                        classData['classCode'],
                      );
                      return GestureDetector(
                        onTap: () => onClassTap(classData['classCode']),
                        onLongPress: () => onEditClass(classData),
                        child: ClassCard(
                          classCode: classData['classCode'],
                          className: classData['className'],
                          status: classData['status'],
                          finalGrade: _convertToDouble(classData['finalGrade']),
                          isHighlighted: isHighlighted,
                          isRelated: isRelated,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
