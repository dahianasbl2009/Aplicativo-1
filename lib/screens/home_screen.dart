import 'package:flutter/material.dart';
import '../models/aprendiz_model.dart';
import '../services/aprendiz_repository.dart';
import '../widgets/aprendiz_form_dialog.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = AprendizRepository();
  List<Aprendiz> _aprendices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarAprendices();
  }

  Future<void> _cargarAprendices() async {
    setState(() => _loading = true);
    try {
      final lista = await _repo.getAprendices();
      setState(() {
        _aprendices = lista;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  // Visualizar Aprendiz (solo lectura)
  void _verAprendiz(Aprendiz aprendiz) {
    showDialog(
      context: context,
      builder: (context) => AprendizFormDialog(
        aprendiz: aprendiz,
        readOnly: true,
      ),
    );
  }

  // Crear o Editar Aprendiz
  void _abrirFormulario({Aprendiz? aprendiz}) async {
    final result = await showDialog<Aprendiz>(
      context: context,
      builder: (context) => AprendizFormDialog(aprendiz: aprendiz),
    );

    if (result != null) {
      if (aprendiz == null) {
        await _repo.crearAprendiz(result);
      } else {
        await _repo.actualizarAprendiz(result);
      }
      _cargarAprendices();
    }
  }

  // Eliminar Aprendiz
  void _eliminarAprendiz(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            const Text('¿Está seguro de que desea eliminar este aprendiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _repo.eliminarAprendiz(id);
      _cargarAprendices();
    }
  }

  // Cerrar Sesión y regresar a Login
  void _cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Aprendices'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _aprendices.isEmpty
              ? const Center(child: Text('No hay aprendices registrados'))
              : ListView.builder(
                  itemCount: _aprendices.length,
                  itemBuilder: (context, index) {
                    final a = _aprendices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Text(a.genero),
                        ),
                        title: Text('${a.nombre1} ${a.apellido1}'),
                        subtitle: Text(
                            'ID: ${a.id} - Nacimiento: ${a.fechaNacimiento.toIso8601String().split('T')[0]}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón Visualizar
                            IconButton(
                              icon: const Icon(Icons.visibility,
                                  color: Colors.blue),
                              tooltip: 'Visualizar',
                              onPressed: () => _verAprendiz(a),
                            ),
                            // Botón Editar
                            IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.orange),
                              tooltip: 'Editar',
                              onPressed: () => _abrirFormulario(aprendiz: a),
                            ),
                            // Botón Eliminar
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Eliminar',
                              onPressed: () => _eliminarAprendiz(a.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Nuevo Aprendiz', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
