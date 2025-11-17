class Configuracion {
  final String id;
  final bool temaOscuro;
  final double garantiaValor; // Garantía fija en soles
  final double moraValor; // Mora por día en soles
  final int moraDiasMaximos; // Días máximos de mora
  final DateTime createdAt;
  final DateTime updatedAt;

  Configuracion({
    required this.id,
    required this.temaOscuro,
    required this.garantiaValor,
    required this.moraValor,
    required this.moraDiasMaximos,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Configuracion.fromJson(Map<String, dynamic> json) {
    return Configuracion(
      id: json['id'],
      temaOscuro: json['tema_oscuro'] ?? false,
      garantiaValor: json['garantia_valor'] != null
          ? (json['garantia_valor'] as num).toDouble()
          : 50.0,
      moraValor: json['mora_valor'] != null
          ? (json['mora_valor'] as num).toDouble()
          : 10.0,
      moraDiasMaximos: json['mora_dias_maximos'] != null
          ? (json['mora_dias_maximos'] as num).toInt()
          : 20,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tema_oscuro': temaOscuro,
      'garantia_valor': garantiaValor,
      'mora_valor': moraValor,
      'mora_dias_maximos': moraDiasMaximos,
    };
  }

  // Calcular garantía (siempre es el valor fijo)
  double calcularGarantia(double monto) {
    return garantiaValor;
  }

  // Calcular mora basada en días de atraso
  double calcularMora(int diasAtraso) {
    // Si excede los días máximos, cobrar solo hasta el máximo
    final diasACobrar =
        diasAtraso > moraDiasMaximos ? moraDiasMaximos : diasAtraso;
    return moraValor * diasACobrar;
  }

  // Calcular mora total máxima posible
  double get moraMaximaPosible {
    return moraValor * moraDiasMaximos;
  }
}
