import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';
import '../helpers/calculations_helper.dart';

class GeneralProgressScreen extends StatefulWidget {
  const GeneralProgressScreen({super.key});

  @override
  _GeneralProgressScreenState createState() => _GeneralProgressScreenState();
}

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

class _GeneralProgressScreenState extends State<GeneralProgressScreen> {
  late Future<List<Map<String, dynamic>>> _progressData;

  @override
  void initState() {
    super.initState();
    _progressData = _fetchProgressData();
  }

  Future<List<Map<String, dynamic>>> _fetchProgressData() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('periods').get();
      return processSnapshotData(snapshot);
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Progreso general',
        showBackButton: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'PROGRESO GENERAL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Visualiza gráficos de tu progreso académico.',
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
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _progressData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar los datos.'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No hay datos disponibles.'),
                    );
                  }

                  final classes = snapshot.data!;
                  final gradedClasses = CalculationsHelper.filterGradedClasses(
                    classes,
                  );
                  final approvedClasses =
                      CalculationsHelper.calculateApprovedClasses(
                        gradedClasses,
                      );
                  const totalCareerClasses = 60;
                  final careerProgress =
                      CalculationsHelper.calculateCareerProgress(
                        approvedClasses,
                        totalCareerClasses,
                      );

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIndicatorCard(
                            title: 'Clases Aprobadas',
                            value: approvedClasses.toString(),
                            color: Color.fromARGB(255, 39, 39, 39),
                          ),
                          _buildIndicatorCard(
                            title: 'Porcentaje Carrera',
                            value: '${careerProgress.toStringAsFixed(1)}%',
                            color: Color.fromARGB(255, 39, 39, 39),
                          ),
                          _buildIndicatorCard(
                            title: 'Total Clases',
                            value: classes.length.toString(),
                            color: Color.fromARGB(255, 39, 39, 39),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color, width: 1),
      ),
      child: Container(
        width: 110,
        height: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 39, 39, 39),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
