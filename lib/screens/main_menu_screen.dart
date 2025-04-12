import 'package:flutter/material.dart';
import 'dart:io'; // Para detectar la plataforma
import 'package:flutter/services.dart'; // Para minimizar en Android/iOS
import '../widgets/custom_app_bar.dart';
import 'flowchart_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  void _handleExit(BuildContext context) {
    try {
      if (Platform.isWindows) {
        print('Cerrando la aplicación en Windows');
        exit(0); // Cierra la aplicación en Windows
      } else if (Platform.isAndroid || Platform.isIOS) {
        print('Minimizando la aplicación en Android/iOS');
        SystemNavigator.pop(); // Minimiza la aplicación en Android/iOS
      } else {
        print('Navegando hacia atrás');
        Navigator.pop(context); // Comportamiento predeterminado
      }
    } catch (e) {
      print('Error al intentar salir o minimizar la aplicación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Sección de registro'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            shrinkWrap: true,
            children: [
              Center(
                child: Image.asset('assets/images/LogoUNICAH.png', height: 150),
              ),
              const SizedBox(height: 24),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text(
                    'Salir',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _handleExit(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
