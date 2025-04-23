import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class AcademicCalendarsScreen extends StatelessWidget {
  const AcademicCalendarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> calendars = [
      {'year': '2025', 'image': 'assets/images/calendars/calendar_2025.png'},
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerWidth = screenWidth * 0.9;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Calendario académico',
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
                      'CALENDARIO ACADÉMICO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Consulta los calendarios académicos por año.',
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
              ...calendars.map((calendar) {
                return Column(
                  children: [
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Año ${calendar['year']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    insetPadding: EdgeInsets.zero,
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: Colors.black,
                                      child: InteractiveViewer(
                                        panEnabled: true,
                                        boundaryMargin: const EdgeInsets.all(
                                          20,
                                        ),
                                        minScale: 0.5,
                                        maxScale: 4.0,
                                        child: Image.asset(
                                          calendar['image']!,
                                          fit: BoxFit.contain,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Center(
                                              child: Text(
                                                'No se pudo cargar la imagen',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 240, 240, 240),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              constraints: BoxConstraints(
                                maxWidth: containerWidth,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  calendar['image']!,
                                  fit: BoxFit.contain,
                                  height: 200,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text(
                                        'No se pudo cargar la imagen',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: containerWidth,
                      child: const Divider(
                        color: Color.fromARGB(255, 200, 200, 200),
                        thickness: 0.5,
                        height: 32.0,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
