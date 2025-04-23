import 'package:flutter/material.dart';

class EditClassDialog extends StatefulWidget {
  final String classCode;
  final String className;
  final String status;
  final double? finalGrade;
  final List<String> allClasses;
  final List<String> dependencies;
  final int academicYear;
  final int academicPeriod;
  final int credits;
  final Function(String, String, String, double?, List<String>, int, int, int)
  onEditClass;

  const EditClassDialog({
    super.key,
    required this.classCode,
    required this.className,
    required this.status,
    required this.finalGrade,
    required this.allClasses,
    required this.dependencies,
    required this.academicYear,
    required this.academicPeriod,
    required this.credits,
    required this.onEditClass,
  });

  @override
  State<EditClassDialog> createState() => _EditClassDialogState();
}

class _EditClassDialogState extends State<EditClassDialog> {
  late TextEditingController _classCodeController;
  late TextEditingController _classNameController;
  late TextEditingController _finalGradeController;
  late TextEditingController _academicYearController;
  late TextEditingController _creditsController;
  String _status = 'No cursada';
  late int _academicPeriod;
  List<String> _selectedDependencies = [];

  @override
  void initState() {
    super.initState();
    _classCodeController = TextEditingController(text: widget.classCode);
    _classNameController = TextEditingController(text: widget.className);
    _finalGradeController = TextEditingController(
      text: widget.finalGrade != null ? widget.finalGrade.toString() : '',
    );
    _academicYearController = TextEditingController(
      text: widget.academicYear.toString(),
    );
    _creditsController = TextEditingController(text: widget.credits.toString());
    _status = widget.status;
    _academicPeriod = widget.academicPeriod;
    _selectedDependencies = List<String>.from(widget.dependencies);
  }

  @override
  void dispose() {
    _classCodeController.dispose();
    _classNameController.dispose();
    _finalGradeController.dispose();
    _academicYearController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Editar Clase'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _classCodeController,
              decoration: const InputDecoration(
                labelText: 'Código de la Clase',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Clase',
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: const [
                DropdownMenuItem(
                  value: 'No cursada',
                  child: Text('No cursada'),
                ),
                DropdownMenuItem(
                  value: 'Cursándola',
                  child: Text('Cursándola'),
                ),
                DropdownMenuItem(value: 'Aprobada', child: Text('Aprobada')),
                DropdownMenuItem(value: 'Reprobada', child: Text('Reprobada')),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _finalGradeController,
              decoration: const InputDecoration(labelText: 'Nota Final'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _academicYearController,
              decoration: const InputDecoration(labelText: 'Año Académico'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Período Académico'),
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
            const Text(
              'Dependencias',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Agregar Dependencia',
              ),
              items:
                  (widget.allClasses..sort((a, b) => a.compareTo(b)))
                      .map(
                        (classCode) => DropdownMenuItem(
                          value: classCode,
                          child: Text(classCode),
                        ),
                      )
                      .toList(),
              onChanged: (selectedClass) {
                if (selectedClass != null &&
                    !_selectedDependencies.contains(selectedClass)) {
                  setState(() {
                    _selectedDependencies.add(selectedClass);
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children:
                  _selectedDependencies.map((dependency) {
                    return Chip(
                      label: Text(dependency),
                      onDeleted: () {
                        setState(() {
                          _selectedDependencies.remove(dependency);
                        });
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedClassCode = _classCodeController.text.trim();
            final updatedClassName = _classNameController.text.trim();
            final updatedFinalGrade =
                _finalGradeController.text.isNotEmpty
                    ? double.tryParse(_finalGradeController.text)
                    : null;
            final updatedAcademicYear =
                int.tryParse(_academicYearController.text.trim()) ?? 0;
            final updatedCredits =
                int.tryParse(_creditsController.text.trim()) ?? 0;

            widget.onEditClass(
              updatedClassCode,
              updatedClassName,
              _status,
              updatedFinalGrade,
              _selectedDependencies,
              updatedAcademicYear,
              _academicPeriod,
              updatedCredits,
            );

            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
