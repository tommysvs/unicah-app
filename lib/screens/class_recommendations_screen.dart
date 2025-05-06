import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicah_app/widgets/custom_app_bar.dart';
import '../helpers/data_processing_helper.dart';

class ClassRecommendationsScreen extends StatefulWidget {
  const ClassRecommendationsScreen({super.key});

  @override
  _ClassRecommendationsScreenState createState() =>
      _ClassRecommendationsScreenState();
}

class _ClassRecommendationsScreenState
    extends State<ClassRecommendationsScreen> {
  int classesPerPeriod = 3;

  List<Map<String, dynamic>> sortClassesByDependencies(
    List<Map<String, dynamic>> classes,
  ) {
    final Map<String, List<String>> graph = {};
    final Map<String, int> inDegree = {};
    final List<Map<String, dynamic>> sortedClasses = [];

    for (var classData in classes) {
      final className = classData['className'];
      final dependencies = classData['dependencies'] as List<String>;

      graph[className] = dependencies;
      inDegree[className] = inDegree[className] ?? 0;

      for (var dependency in dependencies) {
        inDegree[dependency] = (inDegree[dependency] ?? 0) + 1;
      }
    }

    final queue = <String>[];
    inDegree.forEach((key, value) {
      if (value == 0) queue.add(key);
    });

    final visited = <String>{};
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      visited.add(current);

      final currentClass = classes.firstWhere(
        (c) => c['className'] == current,
        orElse:
            () => {
              'className': current,
              'dependencies': [],
              'status': 'No definida',
              'credits': 0,
              'finalGrade': 0,
            },
      );

      sortedClasses.add(currentClass);

      for (var neighbor in graph[current] ?? []) {
        inDegree[neighbor] = inDegree[neighbor]! - 1;
        if (inDegree[neighbor] == 0) queue.add(neighbor);
      }
    }

    final unresolved =
        graph.keys.where((key) => !visited.contains(key)).toList();
    if (unresolved.isNotEmpty) {
      throw Exception(
        'Ciclo detectado en las dependencias de las clases. Clases involucradas: ${unresolved.join(', ')}',
      );
    }

    return sortedClasses;
  }

  Map<String, int> getCurrentPeriod() {
    final now = DateTime.now();
    int year = now.year;
    int period;

    if (now.month >= 1 && now.month <= 3) {
      period = 1;
    } else if (now.month >= 5 && now.month <= 7) {
      period = 2;
    } else if (now.month >= 9 && now.month <= 11) {
      period = 3;
    } else {
      if (now.month == 4) {
        period = 2;
      } else if (now.month == 8) {
        period = 3;
      } else {
        period = 1;
        year++;
      }
    }

    return {'year': year, 'period': period};
  }

  List<List<String>> generateRecommendations(
    List<Map<String, dynamic>> classes,
  ) {
    List<List<String>> recommendations = [];

    List<Map<String, dynamic>> pendingClasses =
        classes.where((c) => c['status'] == 'No cursada').toList();

    List<Map<String, dynamic>> sortedClasses = sortClassesByDependencies(
      pendingClasses,
    );

    Map<String, int> currentPeriod = getCurrentPeriod();
    int period = currentPeriod['period']!;

    final List<String> periodNames = [
      'I',
      'II',
      'III',
      'IV',
      'V',
      'VI',
      'VII',
      'VIII',
      'IX',
      'X',
      'XI',
      'XII',
      'XIII',
    ];

    for (var classData in sortedClasses) {
      if (recommendations.isEmpty ||
          recommendations.last.length >= classesPerPeriod) {
        recommendations.add([]);
        if (recommendations.length > 1) {
          if (period < periodNames.length) {
            period++;
          } else {
            period = 1;
          }
        }
      }

      recommendations.last.add(classData['className']);
    }

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Recomendación de clases',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'RECOMENDACIÓN DE CLASES',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Obtén sugerencias de clases basadas en tus clases aprobadas.',
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
            const Text(
              'Selecciona la cantidad de clases por período:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueAccent),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<int>(
                dropdownColor: Colors.white,
                value: classesPerPeriod,
                items:
                    List.generate(5, (index) => index + 1)
                        .map(
                          (value) => DropdownMenuItem<int>(
                            value: value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              child: Text(
                                '$value clases',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    classesPerPeriod = value!;
                  });
                },
                underline: Container(),
                isExpanded: true,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('periods')
                        .snapshots(),
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

                  List<Map<String, dynamic>> classes =
                      DataProcessingHelper.processSnapshotData(snapshot.data!);

                  List<List<String>> recommendations = generateRecommendations(
                    classes,
                  );

                  return ListView.builder(
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      int year = getCurrentPeriod()['year']! + (index ~/ 3);
                      int period =
                          (getCurrentPeriod()['period']! + index - 1) % 3 + 1;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        elevation: 2,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Año $year - Período $period',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...recommendations[index].map((classCode) {
                                final classDetails = classes.firstWhere(
                                  (c) => c['className'] == classCode,
                                  orElse:
                                      () => {
                                        'className': classCode,
                                        'credits': 0,
                                        'status': 'No definida',
                                      },
                                );
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    classDetails['className'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Créditos: ${classDetails['credits']} - Estado: ${classDetails['status']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  leading: const Icon(
                                    Icons.book,
                                    color: Colors.blueAccent,
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
