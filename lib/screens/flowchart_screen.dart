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

  @override
  void initState() {
    super.initState();
    _loadPeriods();
  }

  Future<void> _loadPeriods() async {
    try {
      final snapshot = await _firestore.collection('periods').get();
      print(
        'Datos cargados desde Firestore: ${snapshot.docs.map((doc) => doc.data())}',
      );
      setState(() {
        periods =
            snapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
      });
    } catch (e) {
      print('Error al cargar los periodos: $e');
    }
  }

  Future<void> _savePeriods() async {
    try {
      final batch = _firestore.batch();
      final collection = _firestore.collection('periods');

      // Eliminar todos los documentos existentes
      final snapshot = await collection.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // Agregar los nuevos periodos
      for (var period in periods) {
        batch.set(collection.doc(), period);
      }

      await batch.commit();
      print('Datos guardados correctamente en Firestore.');
    } catch (e) {
      print('Error al guardar los periodos: $e');
    }
  }

  void _addClass(
    String period,
    String classCode,
    String className,
    double? grade,
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
            },
          ],
        });
      }
    });

    _savePeriods();
  }

  void _showAddClassDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddClassDialog(onAddClass: _addClass);
      },
    );
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text(
            '¿Estás seguro de que deseas borrar todos los datos?',
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
                setState(() {
                  periods = [];
                });
                _savePeriods();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'INGENIERÍA EN CIENCIAS DE LA COMPUTACIÓN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Renderizar las secciones dinámicamente
              ...periods.map((period) {
                return Column(
                  children: [
                    PeriodSection(
                      romanNumber: period['romanNumber'] as String,
                      classes:
                          (period['classes'] as List<dynamic>)
                              .map((e) => Map<String, dynamic>.from(e as Map))
                              .toList(),
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
            heroTag: 'clearJson',
            onPressed: _showClearConfirmationDialog,
            backgroundColor: Colors.grey,
            child: const Icon(
              Icons.delete,
              color: Color.fromARGB(255, 1, 32, 80),
            ),
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
