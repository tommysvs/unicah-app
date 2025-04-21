import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final String classCode;
  final String className;
  final String status;
  final double? finalGrade;
  final bool isHighlighted;
  final bool isRelated;

  const ClassCard({
    Key? key,
    required this.classCode,
    required this.className,
    required this.status,
    this.finalGrade,
    this.isHighlighted = false,
    this.isRelated = false,
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

  Color _getBackgroundColor() {
    if (isHighlighted) {
      return const Color.fromARGB(255, 255, 249, 219);
    } else if (isRelated) {
      return const Color.fromARGB(255, 209, 230, 255);
    } else {
      return Colors.white;
    }
  }

  Color _getTextColor() {
    if (status == 'Aprobada') {
      return Colors.green;
    } else if (status == 'Reprobada') {
      return Colors.red;
    } else {
      return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: _getBackgroundColor(),
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classCode,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      className,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status == 'Aprobada' || status == 'Reprobada'
                          ? '$status: ${finalGrade?.toInt() ?? ''}'
                          : status,
                      style: TextStyle(fontSize: 10, color: _getTextColor()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
