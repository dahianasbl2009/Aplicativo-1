class Aprendiz {
  final int id;
  final String nombre1;
  final String? nombre2;
  final String apellido1;
  final String? apellido2;
  final String genero; // 'M' o 'F'
  final DateTime fechaNacimiento;
  final String departamentoResidencia;
  final String ciudadResidencia;
  
  // Relaciones cargadas mediante JOINS de Supabase (opcionales)
  final String? nombreDepartamento;
  final String? nombreCiudad;

  Aprendiz({
    required this.id,
    required this.nombre1,
    this.nombre2,
    required this.apellido1,
    this.apellido2,
    required this.genero,
    required this.fechaNacimiento,
    required this.departamentoResidencia,
    required this.ciudadResidencia,
    this.nombreDepartamento,
    this.nombreCiudad,
  });

  String get nombreCompleto => 
      '$nombre1 ${nombre2 ?? ''} $apellido1 ${apellido2 ?? ''}'.replaceAll(RegExp(r'\s+'), ' ').trim();

  factory Aprendiz.fromJson(Map<String, dynamic> json) {
    return Aprendiz(
      id: json['id'] as int,
      nombre1: json['nombre1'] as String,
      nombre2: json['nombre2'] as String?,
      apellido1: json['apellido1'] as String,
      apellido2: json['apellido2'] as String?,
      genero: json['genero'] as String,
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento'] as String),
      departamentoResidencia: json['departamento_residencia'] as String,
      ciudadResidencia: json['ciudad_residencia'] as String,
      nombreDepartamento: json['ciudad']?['departamento_rel']?['nombre'] as String?,
      nombreCiudad: json['ciudad']?['nombre'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre1': nombre1,
      'nombre2': nombre2,
      'apellido1': apellido1,
      'apellido2': apellido2,
      'genero': genero,
      'fecha_nacimiento': fechaNacimiento.toIso8601String().split('T')[0],
      'departamento_residencia': departamentoResidencia,
      'ciudad_residencia': ciudadResidencia,
    };
  }
}
