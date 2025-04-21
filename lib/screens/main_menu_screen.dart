import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import '../widgets/custom_app_bar.dart';
import 'flowchart_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  void _handleExit(BuildContext context) {
    try {
      if (Platform.isWindows) {
        exit(0);
      } else if (Platform.isAndroid || Platform.isIOS) {
        SystemNavigator.pop();
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      throw Exception('Error al salir de la aplicación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Sección de registro'),
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
                          color: Colors.blue,
                        ),
                        title: const Text(
                          'Calendarios académicos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {},
                      ),
                    ),
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
                        leading: const Icon(Icons.schema, color: Colors.blue),
                        title: const Text(
                          'Historial gráfico',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                        leading: const Icon(Icons.book, color: Colors.blue),
                        title: const Text(
                          'Historial de clases',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
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
                  'Esta aplicación es solo para uso personal.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
