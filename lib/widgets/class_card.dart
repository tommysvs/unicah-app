import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final String classCode;
  final String className;
  final String status;
  final double? finalGrade;

  const ClassCard({
    Key? key,
    required this.classCode,
    required this.className,
    required this.status,
    this.finalGrade,
  }) : super(key: key);

  Color _getTopBorderColor() {
    switch (status) {
      case 'Aprobada':
        return Colors.green;
      case 'Reprobada':
        return Colors.red;
      case 'Cursándola':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case 'Aprobada':
        return Colors.green;
      case 'Reprobada':
        return Colors.red;
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: _getTopBorderColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
            // Contenido de la tarjeta
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classCode,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    className,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status == 'Aprobada' || status == 'Reprobada'
                        ? '$status: ${finalGrade?.toStringAsFixed(1) ?? ''}'
                        : status,
                    style: TextStyle(fontSize: 10, color: _getTextColor()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
