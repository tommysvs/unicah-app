import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'flowchart_screen.dart';
import 'academic_calendar_screen.dart';
import 'class_history_screen.dart';
import 'general_progress_screen.dart';
import 'class_recommendations_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Registro'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: Image.asset('assets/images/LogoUNICAH.png', height: 150),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  shrinkWrap: true,
                  children: [
                    // Opción: Calendarios académicos
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromARGB(255, 205, 205, 205),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.calendar_month,
                          color: Color.fromARGB(255, 0, 76, 190),
                        ),
                        title: const Text(
                          'Calendario académico',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: const Text(
                          'Fechas importantes del año académico.',
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const AcademicCalendarsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    // Opción: Historial gráfico
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromARGB(255, 205, 205, 205),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.schema,
                          color: Color.fromARGB(255, 0, 76, 190),
                        ),
                        title: const Text(
                          'Historial gráfico',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: const Text(
                          'Avance académico representado gráficamente.',
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FlowchartScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    // Opción: Historial de clases
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromARGB(255, 205, 205, 205),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.book,
                          color: Color.fromARGB(255, 0, 76, 190),
                        ),
                        title: const Text(
                          'Historial de clases',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: const Text(
                          'Clases cursadas y calificaciones obtenidas.',
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ClassHistoryScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    // Opción: Progreso general
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromARGB(255, 205, 205, 205),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.bar_chart,
                          color: Color.fromARGB(255, 0, 76, 190),
                        ),
                        title: const Text(
                          'Progreso general',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: const Text(
                          'Porcentaje de avance en la carrera.',
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const GeneralProgressScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    // Opción: Recomendaciones de clases
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromARGB(255, 205, 205, 205),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.lightbulb,
                          color: Color.fromARGB(255, 0, 76, 190),
                        ),
                        title: const Text(
                          'Recomendación de clases',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: const Text(
                          'Clases recomendadas según el avance de la carrera.',
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const ClassRecommendationsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 16.0,
              left: 32.0,
              right: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Esta aplicación es solo para uso personal y no pretende reemplazar la aplicación oficial de la UNICAH.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
