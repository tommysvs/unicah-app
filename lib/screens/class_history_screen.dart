import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';

class ClassHistoryScreen extends StatelessWidget {
  const ClassHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Historial de clases',
        showBackButton: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('periods').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No hay datos disponibles.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final List<Map<String, dynamic>> classes =
                snapshot.data!.docs.expand((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final classList = data['classes'] as List<dynamic>? ?? [];
                  return classList.whereType<Map<String, dynamic>>().map((
                    classData,
                  ) {
                    return {
                      'className': classData['className'] ?? 'Sin nombre',
                      'finalGrade': classData['finalGrade'] ?? 0,
                      'credits': classData['credits'] ?? 0,
                      'status': classData['status'] ?? 'Sin estado',
                      'academicYear':
                          classData['academicYear']?.toString() ?? '0',
                      'academicPeriod':
                          classData['academicPeriod']?.toString() ??
                          'Sin periodo',
                    };
                  }).toList();
                }).toList();

            final Map<String, Map<String, List<Map<String, dynamic>>>>
            groupedByYearAndPeriod = {};
            for (var classData in classes) {
              final year = classData['academicYear'] as String;

              if (year == '0') continue;

              final period = classData['academicPeriod'] as String;

              if (!groupedByYearAndPeriod.containsKey(year)) {
                groupedByYearAndPeriod[year] = {};
              }
              if (!groupedByYearAndPeriod[year]!.containsKey(period)) {
                groupedByYearAndPeriod[year]![period] = [];
              }
              groupedByYearAndPeriod[year]![period]!.add(classData);
            }

            // Ordenar los años y periodos
            final sortedYears =
                groupedByYearAndPeriod.keys.toList()
                  ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

            // Filtrar las clases válidas (excluir clases con nota 0 y estado "Aprobada" o "No cursada")
            final validClasses =
                classes.where((c) {
                  final grade = c['finalGrade'] as num;
                  final status = c['status'] as String? ?? '';
                  return !(grade == 0 &&
                      (status == 'Aprobada' || status == 'No cursada'));
                }).toList();

            // Calcular el promedio académico
            final totalGrades = validClasses
                .map((c) => c['finalGrade'] as num)
                .reduce((a, b) => a + b);
            final academicAverage = totalGrades / validClasses.length;

            // Calcular el promedio del último período
            final lastYear = sortedYears.last;
            final lastPeriodKeys =
                groupedByYearAndPeriod[lastYear]!.keys.toList();
            lastPeriodKeys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
            final lastPeriod = lastPeriodKeys.last;
            final lastPeriodClasses =
                groupedByYearAndPeriod[lastYear]![lastPeriod]!.where((c) {
                  final grade = c['finalGrade'] as num;
                  final status = c['status'] as String? ?? '';
                  return !(grade == 0 &&
                      (status == 'Aprobada' || status == 'No cursada'));
                }).toList();
            final lastPeriodAverage =
                lastPeriodClasses.isNotEmpty
                    ? lastPeriodClasses
                            .map((c) => c['finalGrade'] as num)
                            .reduce((a, b) => a + b) /
                        lastPeriodClasses.length
                    : 0.0;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'HISTORIAL DE CLASES',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Consulta el historial de clases organizadas por año y periodo.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 30, thickness: 0.8),
                  ...sortedYears.map((year) {
                    final periods = groupedByYearAndPeriod[year]!;

                    final sortedPeriods =
                        periods.keys.toList()..sort(
                          (a, b) => int.parse(a).compareTo(int.parse(b)),
                        );

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ExpansionTile(
                        backgroundColor: Colors.grey[50],
                        title: Text(
                          'Año $year',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          ...sortedPeriods.map((period) {
                            final classes = periods[period]!;

                            // Filtrar las clases válidas (excluir clases con nota 0 y estado "Aprobada" o "No cursada")
                            final validClasses =
                                classes.where((c) {
                                  final grade = c['finalGrade'] as num;
                                  final status = c['status'] as String? ?? '';
                                  return !(grade == 0 &&
                                      (status == 'Aprobada' ||
                                          status == 'No cursada'));
                                }).toList();

                            // Calcular el promedio solo con las clases válidas
                            final average =
                                validClasses.isNotEmpty
                                    ? validClasses
                                            .map((c) => c['finalGrade'] as num)
                                            .reduce((a, b) => a + b) /
                                        validClasses.length
                                    : 0.0;

                            return Column(
                              children: [
                                ExpansionTile(
                                  title: Text('Período $period'),
                                  subtitle: Text(
                                    'Promedio: ${average.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: [
                                    ...classes.map((classData) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Text(classData['className']),
                                            trailing: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    (classData['finalGrade']
                                                                as num) >=
                                                            70
                                                        ? Colors.green
                                                            .withOpacity(0.2)
                                                        : Colors.red
                                                            .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Nota: ${classData['finalGrade']}',
                                                style: TextStyle(
                                                  color:
                                                      (classData['finalGrade']
                                                                  as num) >=
                                                              70
                                                          ? Colors.green
                                                          : Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                                const Divider(thickness: 1),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.school,
                                    color: Colors.black87,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Promedio académico',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${academicAverage.toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.black87,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Promedio del último período',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${lastPeriodAverage.toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
