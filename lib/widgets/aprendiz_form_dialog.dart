import 'package:flutter/material.dart';
import '../models/aprendiz_model.dart';
import '../models/ciudad_model.dart';
import '../models/departamento_model.dart';
import '../services/aprendiz_repository.dart';

class AprendizFormDialog extends StatefulWidget {
  final Aprendiz? aprendiz;
  final bool readOnly;

  const AprendizFormDialog({
    super.key,
    this.aprendiz,
    this.readOnly = false,
  });

  @override
  State<AprendizFormDialog> createState() => _AprendizFormDialogState();
}

class _AprendizFormDialogState extends State<AprendizFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AprendizRepository();

  late TextEditingController _idController;
  late TextEditingController _nombre1Controller;
  late TextEditingController _nombre2Controller;
  late TextEditingController _apellido1Controller;
  late TextEditingController _apellido2Controller;

  String _genero = 'M';
  DateTime _fechaNacimiento = DateTime(2000, 1, 1);
  String? _selectedDepartamento;
  String? _selectedCiudad;

  List<Departamento> _departamentos = [];
  List<Ciudad> _ciudades = [];
  bool _loadingDepartamentos = true;
  bool _loadingCiudades = false;

  @override
  void initState() {
    super.initState();
    final a = widget.aprendiz;
    _idController = TextEditingController(text: a?.id.toString() ?? '');
    _nombre1Controller = TextEditingController(text: a?.nombre1 ?? '');
    _nombre2Controller = TextEditingController(text: a?.nombre2 ?? '');
    _apellido1Controller = TextEditingController(text: a?.apellido1 ?? '');
    _apellido2Controller = TextEditingController(text: a?.apellido2 ?? '');

    if (a != null) {
      _genero = a.genero;
      _fechaNacimiento = a.fechaNacimiento;
      _selectedDepartamento = a.departamentoResidencia;
      _selectedCiudad = a.ciudadResidencia;
    }

    _loadDepartamentos();
  }

  Future<void> _loadDepartamentos() async {
    try {
      final deptos = await _repo.getDepartamentos();
      setState(() {
        _departamentos = deptos;
        _loadingDepartamentos = false;
      });

      if (_selectedDepartamento != null) {
        await _onDepartamentoChanged(_selectedDepartamento, isInitial: true);
      }
    } catch (e) {
      setState(() => _loadingDepartamentos = false);
    }
  }

  Future<void> _onDepartamentoChanged(String? deptoCodigo,
      {bool isInitial = false}) async {
    if (deptoCodigo == null) return;

    setState(() {
      _selectedDepartamento = deptoCodigo;
      if (!isInitial) _selectedCiudad = null;
      _loadingCiudades = true;
    });

    try {
      final ciudades = await _repo.getCiudadesPorDepartamento(deptoCodigo);
      setState(() {
        _ciudades = ciudades;
        _loadingCiudades = false;
      });
    } catch (e) {
      setState(() => _loadingCiudades = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.aprendiz != null;
    final isReadOnly = widget.readOnly;

    return AlertDialog(
      title: Text(
        isReadOnly
            ? 'Detalles del Aprendiz'
            : (isEditing ? 'Editar Aprendiz' : 'Nuevo Aprendiz'),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _idController,
                  enabled: !isEditing && !isReadOnly,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Identificación (ID)'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Campo requerido' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nombre1Controller,
                        enabled: !isReadOnly,
                        decoration:
                            const InputDecoration(labelText: 'Primer Nombre'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _nombre2Controller,
                        enabled: !isReadOnly,
                        decoration:
                            const InputDecoration(labelText: 'Segundo Nombre'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _apellido1Controller,
                        enabled: !isReadOnly,
                        decoration:
                            const InputDecoration(labelText: 'Primer Apellido'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _apellido2Controller,
                        enabled: !isReadOnly,
                        decoration: const InputDecoration(
                            labelText: 'Segundo Apellido'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _genero,
                  decoration: const InputDecoration(labelText: 'Género'),
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text('Masculino (M)')),
                    DropdownMenuItem(value: 'F', child: Text('Femenino (F)')),
                  ],
                  onChanged: isReadOnly
                      ? null
                      : (val) => setState(() => _genero = val!),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                      'Fecha de Nacimiento: ${_fechaNacimiento.toIso8601String().split('T')[0]}'),
                  trailing:
                      isReadOnly ? null : const Icon(Icons.calendar_today),
                  onTap: isReadOnly
                      ? null
                      : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _fechaNacimiento,
                            firstDate: DateTime(1940),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null)
                            setState(() => _fechaNacimiento = picked);
                        },
                ),
                _loadingDepartamentos
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        value: _selectedDepartamento,
                        decoration:
                            const InputDecoration(labelText: 'Departamento'),
                        items: _departamentos.map((d) {
                          return DropdownMenuItem(
                              value: d.codigo, child: Text(d.nombre));
                        }).toList(),
                        onChanged: isReadOnly ? null : _onDepartamentoChanged,
                        validator: (val) =>
                            val == null ? 'Seleccione departamento' : null,
                      ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCiudad,
                  decoration: InputDecoration(
                    labelText: 'Ciudad',
                    suffixIcon: _loadingCiudades
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : null,
                  ),
                  items: _ciudades.map((c) {
                    return DropdownMenuItem(
                        value: c.codigo, child: Text(c.nombre));
                  }).toList(),
                  onChanged: isReadOnly
                      ? null
                      : (val) => setState(() => _selectedCiudad = val),
                  validator: (val) => val == null ? 'Seleccione ciudad' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isReadOnly ? 'Cerrar' : 'Cancelar'),
        ),
        if (!isReadOnly)
          ElevatedButton(
            onPressed: _guardar,
            child: const Text('Guardar'),
          ),
      ],
    );
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final aprendiz = Aprendiz(
        id: int.parse(_idController.text),
        nombre1: _nombre1Controller.text.trim(),
        nombre2: _nombre2Controller.text.trim().isEmpty
            ? null
            : _nombre2Controller.text.trim(),
        apellido1: _apellido1Controller.text.trim(),
        apellido2: _apellido2Controller.text.trim().isEmpty
            ? null
            : _apellido2Controller.text.trim(),
        genero: _genero,
        fechaNacimiento: _fechaNacimiento,
        departamentoResidencia: _selectedDepartamento!,
        ciudadResidencia: _selectedCiudad!,
      );

      Navigator.pop(context, aprendiz);
    }
  }
}
