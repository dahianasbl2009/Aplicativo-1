import '../models/aprendiz_model.dart';
import '../models/ciudad_model.dart';
import '../models/departamento_model.dart';
import 'supabase_service.dart';

class AprendizRepository {
  // Obtener lista completa de departamentos
  Future<List<Departamento>> getDepartamentos() async {
    final response = await SupabaseService.client
        .from('departamento')
        .select()
        .order('nombre', ascending: true);

    return (response as List).map((json) => Departamento.fromJson(json)).toList();
  }

  // Obtener ciudades filtradas por departamento
  Future<List<Ciudad>> getCiudadesPorDepartamento(String deptoCodigo) async {
    final response = await SupabaseService.client
        .from('ciudad')
        .select()
        .eq('departamento', deptoCodigo)
        .order('nombre', ascending: true);

    return (response as List).map((json) => Ciudad.fromJson(json)).toList();
  }

  // Obtener aprendices con información de ciudad y departamento vía Join
  Future<List<Aprendiz>> getAprendices() async {
    final response = await SupabaseService.client
        .from('aprendiz')
        .select('''
          *,
          ciudad:ciudad!fk_aprendiz_ciudad(
            nombre,
            departamento_rel:departamento!fk_ciudad_departamento(nombre)
          )
        ''')
        .order('id', ascending: true);

    return (response as List).map((json) => Aprendiz.fromJson(json)).toList();
  }

  // Crear aprendiz
  Future<void> crearAprendiz(Aprendiz aprendiz) async {
    await SupabaseService.client
        .from('aprendiz')
        .insert(aprendiz.toJson());
  }

  // Actualizar aprendiz
  Future<void> actualizarAprendiz(Aprendiz aprendiz) async {
    await SupabaseService.client
        .from('aprendiz')
        .update(aprendiz.toJson())
        .eq('id', aprendiz.id);
  }

  // Eliminar aprendiz
  Future<void> eliminarAprendiz(int id) async {
    await SupabaseService.client
        .from('aprendiz')
        .delete()
        .eq('id', id);
  }
}
