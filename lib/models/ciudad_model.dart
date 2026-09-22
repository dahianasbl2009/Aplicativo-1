class Ciudad {
  final String departamento;
  final String codigo;
  final String nombre;

  Ciudad({
    required this.departamento,
    required this.codigo,
    required this.nombre,
  });

  factory Ciudad.fromJson(Map<String, dynamic> json) {
    return Ciudad(
      departamento: json['departamento'] as String,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departamento': departamento,
      'codigo': codigo,
      'nombre': nombre,
    };
  }
}
