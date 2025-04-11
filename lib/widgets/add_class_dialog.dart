import 'package:flutter/material.dart';

class AddClassDialog extends StatefulWidget {
  final Function(
    String period,
    String classCode,
    String className,
    double? grade,
  )
  onAddClass;

  const AddClassDialog({Key? key, required this.onAddClass}) : super(key: key);

  @override
  State<AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<AddClassDialog> {
  final _classCodeController = TextEditingController();
  final _classNameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _periodController = TextEditingController();

  void _submit() {
    final period = _periodController.text;
    final classCode = _classCodeController.text;
    final className = _classNameController.text;
    final gradeText = _gradeController.text;
    final grade = gradeText.isNotEmpty ? double.tryParse(gradeText) : null;

    if (period.isEmpty || classCode.isEmpty || className.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos obligatorios.'),
        ),
      );
      return;
    }

    // Si no se ingresa una nota, asumimos que la clase no ha sido llevada
    widget.onAddClass(period, classCode, className, grade);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Agregar clase'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _periodController,
              decoration: const InputDecoration(
                labelText: 'Periodo (en números romanos)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _classCodeController,
              decoration: const InputDecoration(
                labelText: 'Código de la clase',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la clase',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _gradeController,
              decoration: const InputDecoration(labelText: 'Nota (opcional)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 76, 190),
          ),
          child: const Text('Agregar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
