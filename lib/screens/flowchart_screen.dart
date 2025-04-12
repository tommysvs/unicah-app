import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _loadPeriods();
  }

  Future<void> _loadPeriods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? periodsData = prefs.getString('periods');
      if (periodsData != null) {
        final List<dynamic> decodedData =
            json.decode(periodsData) as List<dynamic>;
        setState(() {
          periods =
              decodedData
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();
        });
      }
    } catch (e) {
      print('Error al cargar los periodos: $e');
      setState(() {
        periods = [];
      });
    }
  }

  Future<void> _savePeriods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('periods', json.encode(periods));
    } catch (e) {
      print('Error al guardar los periodos: $e');
    }
  }

  Future<void> _clearPeriods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('periods');
      setState(() {
        periods = [];
      });
      print('Datos limpiados. periods ahora está vacío.');
    } catch (e) {
      print('Error al limpiar los periodos: $e');
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

    print('Estructura actual de periods: $periods');
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
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _clearPeriods(); // Llama a la función para borrar los datos
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Botón rojo para "Eliminar"
              ),
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
            onPressed:
                _showClearConfirmationDialog, // Llama al cuadro de diálogo
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
