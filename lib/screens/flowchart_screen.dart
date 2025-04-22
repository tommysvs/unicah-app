import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/period_section.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/add_class_dialog.dart';
import '../widgets/edit_class_dialog.dart';
import '../widgets/delete_class_dialog.dart';
import '../utils/pdf_exporter.dart';

class FlowchartScreen extends StatefulWidget {
  const FlowchartScreen({super.key});

  @override
  State<FlowchartScreen> createState() => _FlowchartScreenState();
}

class _FlowchartScreenState extends State<FlowchartScreen> {
  List<Map<String, dynamic>> periods = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _highlightedClassCode;
  Set<String> _relatedClasses = {};

  @override
  void initState() {
    super.initState();
    _loadPeriods();
  }

  Future<void> _loadPeriods() async {
    try {
      final snapshot = await _firestore.collection('periods').get();

      setState(() {
        periods = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      throw Exception('Error al cargar los periodos: $e');
    }
  }

  Future<void> _savePeriods() async {
    try {
      final batch = _firestore.batch();
      final collection = _firestore.collection('periods');

      final snapshot = await collection.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      for (var period in periods) {
        batch.set(collection.doc(), period);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error al guardar los periodos: $e');
    }
  }

  int _romanToInt(String roman) {
    final romanMap = {
      'I': 1,
      'II': 2,
      'III': 3,
      'IV': 4,
      'V': 5,
      'VI': 6,
      'VII': 7,
      'VIII': 8,
      'IX': 9,
      'X': 10,
      'XI': 11,
      'XII': 12,
      'XIII': 13,
      'XIV': 14,
      'XV': 15,
    };

    return romanMap[roman] ?? 0;
  }

  List<Map<String, dynamic>> _getSortedPeriods() {
    final sortedPeriods = List<Map<String, dynamic>>.from(periods);
    sortedPeriods.sort((a, b) {
      final romanA = a['romanNumber'] as String;
      final romanB = b['romanNumber'] as String;
      return _romanToInt(romanA).compareTo(_romanToInt(romanB));
    });
    return sortedPeriods;
  }

  void _showAddClassDialog() {
    final allClasses =
        periods
            .expand((period) => period['classes'])
            .map((classData) => classData['classCode'] as String)
            .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AddClassDialog(
          onAddClass: _addClass,
          availableClasses: allClasses,
        );
      },
    );
  }

  void _addClass(
    String period,
    String classCode,
    String className,
    double? grade,
    List<String> dependencies,
  ) {
    final status =
        grade == null ? 'No cursada' : (grade >= 70 ? 'Aprobada' : 'Reprobada');

    setState(() {
      final periodIndex = periods.indexWhere((p) => p['romanNumber'] == period);

      if (periodIndex != -1) {
        final classes = periods[periodIndex]['classes'] as List<dynamic>;
        classes.add({
          'classCode': classCode,
          'className': className,
          'status': status,
          'finalGrade': grade,
          'dependencies': dependencies,
        });
      } else {
        periods.add({
          'romanNumber': period,
          'classes': [
            {
              'classCode': classCode,
              'className': className,
              'status': status,
              'finalGrade': grade,
              'dependencies': dependencies,
            },
          ],
        });
      }
    });

    _savePeriods();
  }

  void _showEditClassDialog(String period, Map<String, dynamic> classData) {
    final allClasses =
        periods
            .expand((p) => p['classes'])
            .map((c) => c['classCode'] as String)
            .toList();

    showDialog(
      context: context,
      builder: (context) {
        return EditClassDialog(
          classCode: classData['classCode'] as String,
          className: classData['className'] as String,
          status: classData['status'] as String,
          finalGrade: classData['finalGrade'] as double?,
          allClasses: allClasses,
          dependencies:
              (classData['dependencies'] as List<dynamic>?)?.cast<String>() ??
              [],
          onEditClass: (
            updatedClassCode,
            updatedClassName,
            updatedStatus,
            updatedFinalGrade,
            updatedDependencies,
          ) {
            _editClass(
              period,
              classData['classCode'],
              updatedClassCode,
              updatedClassName,
              updatedStatus,
              updatedFinalGrade,
              updatedDependencies,
            );
          },
        );
      },
    );
  }

  void _editClass(
    String period,
    String originalClassCode,
    String updatedClassCode,
    String updatedClassName,
    String updatedStatus,
    double? updatedFinalGrade,
    List<String> updatedDependencies,
  ) {
    setState(() {
      final periodIndex = periods.indexWhere((p) => p['romanNumber'] == period);

      if (periodIndex != -1) {
        final classes = periods[periodIndex]['classes'] as List<dynamic>;
        final classIndex = classes.indexWhere(
          (c) => c['classCode'] == originalClassCode,
        );

        if (classIndex != -1) {
          classes[classIndex] = {
            'classCode': updatedClassCode,
            'className': updatedClassName,
            'status': updatedStatus,
            'finalGrade': updatedFinalGrade,
            'dependencies': updatedDependencies,
          };
        }
      }
    });

    _savePeriods();
  }

  void _showDeleteClassDialog() {
    final allClasses =
        periods
            .expand((period) => period['classes'])
            .map((classData) => classData['classCode'] as String)
            .toList();

    showDialog(
      context: context,
      builder: (context) {
        return DeleteClassDialog(
          allClasses: allClasses,
          onDeleteClass: (selectedClass) {
            _deleteClass(selectedClass);
          },
        );
      },
    );
  }

  void _deleteClass(String classCode) {
    setState(() {
      for (var period in periods) {
        final classes = period['classes'] as List<dynamic>;
        classes.removeWhere((classData) => classData['classCode'] == classCode);
      }
    });
    _savePeriods();
  }

  Set<String> _getRelatedClasses(String classCode) {
    final relatedClasses = <String>{};

    for (var period in periods) {
      for (var classData in period['classes']) {
        final dependencies =
            (classData['dependencies'] as List<dynamic>?)?.cast<String>() ??
            <String>[];

        if (classData['classCode'] == classCode) {
          relatedClasses.addAll(dependencies);
        }

        if (dependencies.contains(classCode)) {
          relatedClasses.add(classData['classCode']);
        }
      }
    }

    return relatedClasses;
  }

  void _onClassTap(String classCode) {
    setState(() {
      _highlightedClassCode = classCode;
      _relatedClasses = _getRelatedClasses(classCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalClasses =
        periods.expand((period) => period['classes'] as List<dynamic>).toList();

    final gradedClasses =
        totalClasses
            .where(
              (classData) =>
                  classData['finalGrade'] != null &&
                  classData['finalGrade'] != 0,
            )
            .toList();

    final grades =
        gradedClasses
            .map((classData) => classData['finalGrade'] as double)
            .toList();
    final averageGrade =
        grades.isNotEmpty
            ? (grades.reduce((a, b) => a + b) / grades.length)
            : 0;

    final approvedClasses =
        gradedClasses
            .where((classData) => classData['status'] == 'Aprobada')
            .length;

    const totalCareerClasses = 60;
    final careerProgress = (approvedClasses / totalCareerClasses) * 100;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Historial gráfico',
        showBackButton: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'HISTORIAL GRÁFICO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'INGENIERÍA EN CIENCIAS DE LA COMPUTACIÓN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16.0,
                      runSpacing: 8.0,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 0, 76, 190),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                grades.isNotEmpty
                                    ? 'Promedio total: ${averageGrade.toStringAsFixed(2)}%'
                                    : 'Promedio total: N/A',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 0, 76, 190),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                'Clases Aprobadas: $approvedClasses',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 0, 76, 190),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                'Porcentaje de carrera: ${careerProgress.toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ..._getSortedPeriods().map((period) {
                return Column(
                  children: [
                    PeriodSection(
                      romanNumber: period['romanNumber'] as String,
                      classes:
                          (period['classes'] as List<dynamic>)
                              .map((e) => Map<String, dynamic>.from(e as Map))
                              .toList(),
                      highlightedClassCode: _highlightedClassCode,
                      relatedClasses: _relatedClasses,
                      onClassTap: _onClassTap,
                      onEditClass: (classData) {
                        _showEditClassDialog(period['romanNumber'], classData);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 0, 76, 190),
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed:
                    () => PDFExporter.exportToPDF(
                      periods,
                      'Historial Gráfico',
                      'Ingeniería en Ciencias de la Computación',
                    ),
                icon: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'Exportar a PDF',
              ),
              const VerticalDivider(
                color: Colors.white,
                thickness: 1,
                width: 16,
                indent: 8,
                endIndent: 8,
              ),
              IconButton(
                onPressed: _showDeleteClassDialog,
                icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                tooltip: 'Eliminar clase',
              ),
              const VerticalDivider(
                color: Colors.white,
                thickness: 1,
                width: 16,
                indent: 8,
                endIndent: 8,
              ),
              IconButton(
                onPressed: _showAddClassDialog,
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                tooltip: 'Agregar clase',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
