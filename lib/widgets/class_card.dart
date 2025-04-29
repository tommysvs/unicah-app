import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final String classCode;
  final String className;
  final String status;
  final double? finalGrade;
  final bool isHighlighted;
  final bool isRelated;

  const ClassCard({
    super.key,
    required this.classCode,
    required this.className,
    required this.status,
    this.finalGrade,
    this.isHighlighted = false,
    this.isRelated = false,
  });

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
    final screenWidth = MediaQuery.of(context).size.width;

    final dynamicWidth = (screenWidth / (screenWidth > 1080 ? 3 : 2)).clamp(
      90.0,
      150.0,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: dynamicWidth, maxHeight: 100.0),
      child: IntrinsicWidth(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          color: _getBackgroundColor(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: _getTopBorderColor(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 4.0,
                    bottom: 4.0,
                    left: 12.0,
                    right: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        classCode,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        className,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status == 'Aprobada' || status == 'Reprobada'
                            ? '$status: ${finalGrade?.toInt() ?? ''}%'
                            : status,
                        style: TextStyle(fontSize: 9, color: _getTextColor()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
