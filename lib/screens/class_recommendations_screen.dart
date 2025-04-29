import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicah_app/widgets/custom_app_bar.dart';

class ClassRecommendationsScreen extends StatefulWidget {
  const ClassRecommendationsScreen({super.key});

  @override
  _ClassRecommendationsScreenState createState() =>
      _ClassRecommendationsScreenState();
}

class _ClassRecommendationsScreenState
    extends State<ClassRecommendationsScreen> {
  int classesPerPeriod = 3;

  // Método para procesar los datos del snapshot
  List<Map<String, dynamic>> processSnapshotData(QuerySnapshot snapshot) {
    return snapshot.docs.expand((doc) {
      final data = doc.data() as Map<String, dynamic>;

      final classList = data['classes'] as List<dynamic>? ?? [];
      return classList.whereType<Map<String, dynamic>>().map((classData) {
        return {
          'className': classData['className'] ?? 'Sin nombre',
          'finalGrade': classData['finalGrade'] ?? 0,
          'credits': classData['credits'] ?? 0,
          'status': classData['status'] ?? 'Sin estado',
          'dependencies': List<String>.from(classData['dependencies'] ?? []),
        };
      }).toList();
    }).toList();
  }

  // Método para ordenar las clases según las dependencias
  List<Map<String, dynamic>> sortClassesByDependencies(
    List<Map<String, dynamic>> classes,
  ) {
    final Map<String, List<String>> graph = {};
    final Map<String, int> inDegree = {};
    final List<Map<String, dynamic>> sortedClasses = [];

    // Construir el grafo y calcular el grado de entrada (in-degree)
    for (var classData in classes) {
      final className = classData['className'];
      final dependencies = classData['dependencies'] as List<String>;

      graph[className] = dependencies;
      inDegree[className] = inDegree[className] ?? 0;

      for (var dependency in dependencies) {
        inDegree[dependency] = (inDegree[dependency] ?? 0) + 1;
      }
    }

    // Encontrar nodos sin dependencias (in-degree == 0)
    final queue = <String>[];
    inDegree.forEach((key, value) {
      if (value == 0) queue.add(key);
    });

    // Ordenamiento topológico
    final visited = <String>{};
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      visited.add(current);

      // Manejar el caso en que no se encuentre la clase
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

    // Verificar si hay ciclos
    final unresolved =
        graph.keys.where((key) => !visited.contains(key)).toList();
    if (unresolved.isNotEmpty) {
      throw Exception(
        'Ciclo detectado en las dependencias de las clases. Clases involucradas: ${unresolved.join(', ')}',
      );
    }

    return sortedClasses;
  }

  // Método único para calcular el período actual
  Map<String, int> getCurrentPeriod() {
    final now = DateTime.now();
    int year = now.year;
    int period;

    if (now.month >= 1 && now.month <= 3) {
      period = 1; // Primer período
    } else if (now.month >= 5 && now.month <= 7) {
      period = 2; // Segundo período
    } else if (now.month >= 9 && now.month <= 11) {
      period = 3; // Tercer período
    } else {
      // Si estamos en un mes de vacaciones (Abril, Agosto, Diciembre)
      if (now.month == 4) {
        period = 2; // Próximo período es el segundo
      } else if (now.month == 8) {
        period = 3; // Próximo período es el tercero
      } else {
        period = 1; // Próximo período es el primero del siguiente año
        year++;
      }
    }

    // Evitar períodos pasados
    if (year == 2025 && period == 1) {
      period = 2; // Saltar el período 1 de 2025
    }

    return {'year': year, 'period': period};
  }

  // Método para generar recomendaciones dinámicas
  List<List<String>> generateRecommendations(
    List<Map<String, dynamic>> classes,
  ) {
    List<List<String>> recommendations = [];
    List<String> approvedClasses =
        classes
            .where((c) => c['status'] == 'Aprobada')
            .map((c) => c['className'] as String)
            .toList();

    List<Map<String, dynamic>> pendingClasses =
        classes.where((c) => c['status'] == 'No cursada').toList();

    // Ordenar las clases pendientes según las dependencias
    List<Map<String, dynamic>> sortedClasses = sortClassesByDependencies(
      pendingClasses,
    );

    // Usar el método único de getCurrentPeriod
    Map<String, int> currentPeriod = getCurrentPeriod();
    int year = currentPeriod['year']!;
    int period = currentPeriod['period']!;

    // Lista de períodos personalizados
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

    // Generar recomendaciones dinámicamente
    for (var classData in sortedClasses) {
      if (recommendations.isEmpty ||
          recommendations.last.length >= classesPerPeriod) {
        recommendations.add([]);
        if (recommendations.length > 1) {
          // Avanzar al siguiente período
          if (period < periodNames.length) {
            period++;
          } else {
            period = 1;
            year++;
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
            const Text(
              'Selecciona la cantidad de clases por período:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<int>(
              value: classesPerPeriod,
              items:
                  List.generate(5, (index) => index + 1)
                      .map(
                        (value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value clases'),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  classesPerPeriod = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Recomendaciones:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

                  // Procesar los datos del snapshot
                  List<Map<String, dynamic>> classes = processSnapshotData(
                    snapshot.data!,
                  );

                  // Generar recomendaciones
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
                          horizontal: 16,
                        ),
                        elevation: 4,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Año $year - Período $period',
                                style: const TextStyle(
                                  fontSize: 16,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Créditos: ${classDetails['credits']} - Estado: ${classDetails['status']}',
                                    style: const TextStyle(
                                      fontSize: 12,
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
