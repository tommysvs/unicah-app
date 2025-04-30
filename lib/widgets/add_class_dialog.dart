import 'package:flutter/material.dart';

class AddClassDialog extends StatefulWidget {
  final Function(
    String period,
    String classCode,
    String className,
    double? grade,
    List<String> dependencies,
    int academicYear,
    int academicPeriod,
    int credits,
  )
  onAddClass;

  final List<String> availableClasses;

  const AddClassDialog({
    super.key,
    required this.onAddClass,
    required this.availableClasses,
  });

  @override
  State<AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<AddClassDialog> {
  final _classCodeController = TextEditingController();
  final _classNameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _periodController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _creditsController = TextEditingController();
  int _academicPeriod = 1; // Valor inicial para el período académico
  final List<String> _dependencies = [];

  void _submit() {
    final period = _periodController.text;
    final classCode = _classCodeController.text;
    final className = _classNameController.text;
    final gradeText = _gradeController.text;
    final grade = gradeText.isNotEmpty ? double.tryParse(gradeText) : null;
    final academicYearText = _academicYearController.text;
    final creditsText = _creditsController.text;

    if (period.isEmpty ||
        classCode.isEmpty ||
        className.isEmpty ||
        academicYearText.isEmpty ||
        creditsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos obligatorios.'),
        ),
      );
      return;
    }

    final academicYear = int.tryParse(academicYearText);
    final credits = int.tryParse(creditsText);

    if (academicYear == null || credits == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, ingresa valores válidos para el año académico y los créditos.',
          ),
        ),
      );
      return;
    }

    widget.onAddClass(
      period,
      classCode,
      className,
      grade,
      _dependencies,
      academicYear,
      _academicPeriod,
      credits,
    );
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
            const SizedBox(height: 8),
            TextField(
              controller: _academicYearController,
              decoration: const InputDecoration(labelText: 'Año académico'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              dropdownColor: Colors.white,
              decoration: const InputDecoration(labelText: 'Período académico'),
              value: _academicPeriod,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
              ],
              onChanged: (value) {
                setState(() {
                  _academicPeriod = value ?? 1;
                });
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _creditsController,
              decoration: const InputDecoration(labelText: 'Créditos'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              decoration: const InputDecoration(
                labelText: 'Agregar dependencia',
              ),
              items:
                  widget.availableClasses
                      .map(
                        (classCode) => DropdownMenuItem<String>(
                          value: classCode,
                          child: Text(classCode),
                        ),
                      )
                      .toList()
                    ..sort((a, b) => a.value!.compareTo(b.value!)),
              onChanged: (value) {
                if (value != null && !_dependencies.contains(value)) {
                  setState(() {
                    _dependencies.add(value);
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  _dependencies
                      .map(
                        (dependency) => Chip(
                          label: Text(dependency),
                          onDeleted: () {
                            setState(() {
                              _dependencies.remove(dependency);
                            });
                          },
                        ),
                      )
                      .toList(),
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
