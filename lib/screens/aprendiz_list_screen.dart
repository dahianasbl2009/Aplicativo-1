import 'package:flutter/material.dart';
import '../models/aprendiz_model.dart';
import '../services/aprendiz_repository.dart';
import '../widgets/aprendiz_form_dialog.dart';

class AprendizListScreen extends StatefulWidget {
  const AprendizListScreen({super.key});

  @override
  State<AprendizListScreen> createState() => _AprendizListScreenState();
}

class _AprendizListScreenState extends State<AprendizListScreen> {
  final _repo = AprendizRepository();
  List<Aprendiz> _aprendices = [];
  List<Aprendiz> _filteredAprendices = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarAprendices();
  }

  Future<void> _cargarAprendices() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repo.getAprendices();
      setState(() {
        _aprendices = list;
        _filteredAprendices = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: \$e')),
        );
      }
    }
  }

  void _filtrar(String query) {
    setState(() {
      _filteredAprendices = _aprendices.where((a) {
        final full = '\${a.id} \${a.nombreCompleto}'.toLowerCase();
        return full.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _abrirFormulario([Aprendiz? aprendiz]) async {
    final result = await showDialog<Aprendiz>(
      context: context,
      builder: (_) => AprendizFormDialog(aprendiz: aprendiz),
    );

    if (result != null) {
      try {
        if (aprendiz == null) {
          await _repo.crearAprendiz(result);
        } else {
          await _repo.actualizarAprendiz(result);
        }
        _cargarAprendices();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: \$e')),
          );
        }
      }
    }
  }

  Future<void> _eliminarAprendiz(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar al aprendiz con ID \$id?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _repo.eliminarAprendiz(id);
        _cargarAprendices();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: \$e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIRA - Sistema de Información de Aprendices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarAprendices,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por ID o Nombre',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filtrar,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _abrirFormulario(),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Aprendiz'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Nombre Completo')),
                            DataColumn(label: Text('Género')),
                            DataColumn(label: Text('F. Nacimiento')),
                            DataColumn(label: Text('Ubicación')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: _filteredAprendices.map((a) {
                            return DataRow(cells: [
                              DataCell(Text(a.id.toString())),
                              DataCell(Text(a.nombreCompleto)),
                              DataCell(Text(a.genero)),
                              DataCell(Text(a.fechaNacimiento.toIso8601String().split('T')[0])),
                              DataCell(Text('\${a.nombreCiudad ?? a.ciudadResidencia}, \${a.nombreDepartamento ?? a.departamentoResidencia}')),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _abrirFormulario(a),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _eliminarAprendiz(a.id),
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
