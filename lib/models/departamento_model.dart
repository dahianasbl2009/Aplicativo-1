class Departamento {
  final String codigo;
  final String nombre;

  Departamento({
    required this.codigo,
    required this.nombre,
  });

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nombre': nombre,
    };
  }
}
