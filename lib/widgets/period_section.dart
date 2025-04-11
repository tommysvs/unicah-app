import 'package:flutter/material.dart';
import 'class_card.dart';

class PeriodSection extends StatelessWidget {
  final String romanNumber;
  final List<Map<String, dynamic>> classes;

  const PeriodSection({
    Key? key,
    required this.romanNumber,
    required this.classes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(105, 224, 224, 224),
            Colors.transparent,
            Colors.transparent,
          ], // Gris más claro
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children:
                    classes.map((classData) {
                      return ClassCard(
                        classCode: classData['classCode'],
                        className: classData['className'],
                        status: classData['status'],
                        finalGrade: classData['finalGrade'],
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
