import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/period_section.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/add_class_dialog.dart';
import '../widgets/edit_class_dialog.dart';
import '../widgets/delete_class_dialog.dart';
import '../utils/pdf_exporter.dart';
import '../helpers/calculations_helper.dart';

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
    int academicYear,
    int academicPeriod,
    int credits,
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
          'academicYear': academicYear,
          'academicPeriod': academicPeriod,
          'credits': credits,
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
              'academicYear': academicYear,
              'academicPeriod': academicPeriod,
              'credits': credits,
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
          classCode: (classData['classCode'] as String?) ?? 'N/A',
          className: (classData['className'] as String?) ?? 'Sin nombre',
          status: (classData['status'] as String?) ?? 'No cursada',
          finalGrade: _convertToDouble(classData['finalGrade']),
          allClasses: allClasses,
          dependencies:
              (classData['dependencies'] as List<dynamic>?)?.cast<String>() ??
              [],
          academicYear: (classData['academicYear'] as int?) ?? 0,
          academicPeriod: (classData['academicPeriod'] as int?) ?? 1,
          credits: (classData['credits'] as int?) ?? 0,
          onEditClass: (
            updatedClassCode,
            updatedClassName,
            updatedStatus,
            updatedFinalGrade,
            updatedDependencies,
            updatedAcademicYear,
            updatedAcademicPeriod,
            updatedCredits,
          ) {
            _editClass(
              period,
              classData['classCode'],
              updatedClassCode,
              updatedClassName,
              updatedStatus,
              updatedFinalGrade,
              updatedDependencies,
              updatedAcademicYear,
              updatedAcademicPeriod,
              updatedCredits,
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
    int updatedAcademicYear,
    int updatedAcademicPeriod,
    int updatedCredits,
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
            'academicYear': updatedAcademicYear,
            'academicPeriod': updatedAcademicPeriod,
            'credits': updatedCredits,
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

  bool _showAdditionalButtons = false;

  @override
  Widget build(BuildContext context) {
    final totalClasses =
        periods
            .expand(
              (period) => (period['classes'] as List<dynamic>).map(
                (e) => Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();

    final gradedClasses = CalculationsHelper.filterGradedClasses(totalClasses);
    final averageGrade = CalculationsHelper.calculateAverageGrade(
      gradedClasses,
    );
    final approvedClasses = CalculationsHelper.calculateApprovedClasses(
      gradedClasses,
    );
    final careerProgress = CalculationsHelper.calculateCareerProgress(
      approvedClasses,
    );

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
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 0, 76, 190),
                                    Color.fromARGB(255, 0, 90, 240),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                gradedClasses.isNotEmpty
                                    ? 'Índice académico: ${averageGrade.toStringAsFixed(2)}%'
                                    : 'Índice académico: N/A',
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
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 0, 76, 190),
                                    Color.fromARGB(255, 0, 90, 240),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
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
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 0, 76, 190),
                                    Color.fromARGB(255, 0, 90, 240),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
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
              const Divider(height: 30, thickness: 0.8),
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
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (_showAdditionalButtons)
            Positioned(
              bottom: 200,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'export',
                onPressed: () {
                  PDFExporter.exportToPDF(
                    periods,
                    'Historial Gráfico',
                    'Ingeniería en Ciencias de la Computación',
                  );
                  setState(() {
                    _showAdditionalButtons = false;
                  });
                },
                backgroundColor: const Color.fromARGB(255, 39, 39, 39),
                child: const Icon(Icons.picture_as_pdf, color: Colors.white),
              ),
            ),
          if (_showAdditionalButtons)
            Positioned(
              bottom: 140,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'add',
                onPressed: () {
                  _showAddClassDialog();
                  setState(() {
                    _showAdditionalButtons = false;
                  });
                },
                backgroundColor: const Color.fromARGB(255, 39, 39, 39),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          if (_showAdditionalButtons)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'delete',
                onPressed: () {
                  _showDeleteClassDialog();
                  setState(() {
                    _showAdditionalButtons = false;
                  });
                },
                backgroundColor: const Color.fromARGB(255, 39, 39, 39),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showAdditionalButtons = !_showAdditionalButtons;
                });
              },
              backgroundColor:
                  _showAdditionalButtons
                      ? const Color.fromARGB(255, 27, 27, 27)
                      : const Color.fromARGB(255, 39, 39, 39),

              child: Icon(
                _showAdditionalButtons ? Icons.close : Icons.menu,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
