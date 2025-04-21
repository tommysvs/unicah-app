import 'package:flutter/material.dart';

class DeleteClassDialog extends StatelessWidget {
  final List<String> allClasses;
  final Function(String) onDeleteClass;

  const DeleteClassDialog({
    Key? key,
    required this.allClasses,
    required this.onDeleteClass,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? selectedClass;

    return AlertDialog(
      title: const Text('Eliminar clase'),
      content: DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Selecciona una clase'),
        items:
            allClasses
                .map(
                  (classCode) => DropdownMenuItem(
                    value: classCode,
                    child: Text(classCode),
                  ),
                )
                .toList(),
        onChanged: (value) {
          selectedClass = value;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedClass != null) {
              onDeleteClass(selectedClass!);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, selecciona una clase.'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}
