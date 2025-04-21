import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/period_section.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/add_class_dialog.dart';

class FlowchartScreen extends StatefulWidget {
  const FlowchartScreen({Key? key}) : super(key: key);

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

  void _showDeleteClassDialog() {
    final allClasses =
        periods
            .expand((period) => period['classes'])
            .map((classData) => classData['classCode'] as String)
            .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedClass;

        return AlertDialog(
          title: const Text('Eliminar Clase'),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Selecciona una clase',
            ),
            items:
                allClasses
                    .map(
                      (classCode) => DropdownMenuItem(
                        value: classCode,
                        child: Text(classCode),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              selectedClass = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedClass != null) {
                  _deleteClass(selectedClass!);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, selecciona una clase.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
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

  void _onClassTap(String classCode) {
    setState(() {
      _highlightedClassCode = classCode;
      _relatedClasses = _getRelatedClasses(classCode);
    });
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

  @override
  Widget build(BuildContext context) {
    final totalClasses =
        periods.expand((period) => period['classes'] as List<dynamic>).toList();

    final grades =
        totalClasses
            .where((classData) => classData['finalGrade'] != null)
            .map((classData) => classData['finalGrade'] as double)
            .toList();
    final averageGrade =
        grades.isNotEmpty
            ? (grades.reduce((a, b) => a + b) / grades.length)
            : 0;

    final approvedClasses =
        totalClasses
            .where((classData) => classData['status'] == 'Aprobada')
            .length;

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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'INGENIERÍA EN CIENCIAS DE LA COMPUTACIÓN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                    ? 'Promedio Total: ${averageGrade.toStringAsFixed(2)}'
                                    : 'Promedio Total: N/A',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
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
                                  fontSize: 14,
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
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'deleteClass',
            onPressed: _showDeleteClassDialog,
            backgroundColor: const Color.fromARGB(255, 0, 76, 190),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'addClass',
            onPressed: _showAddClassDialog,
            backgroundColor: const Color.fromARGB(255, 0, 76, 190),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
