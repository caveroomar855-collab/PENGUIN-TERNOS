enum TipoValor {
  porcentaje,
  fijo;

  String get displayName {
    switch (this) {
      case TipoValor.porcentaje:
        return 'Porcentaje';
      case TipoValor.fijo:
        return 'Fijo';
    }
  }

  static TipoValor fromString(String tipo) {
    return TipoValor.values.firstWhere(
      (e) => e.name == tipo.toLowerCase(),
      orElse: () => TipoValor.fijo,
    );
  }
}

class Configuracion {
  final String id;
  final bool temaOscuro;
  final TipoValor garantiaTipo;
  final double garantiaValor;
  final TipoValor moraTipo;
  final double moraValor;
  final double moraMaxima;
  final TipoValor prolongacionTipo;
  final double prolongacionValor;
  final DateTime createdAt;
  final DateTime updatedAt;

  Configuracion({
    required this.id,
    required this.temaOscuro,
    required this.garantiaTipo,
    required this.garantiaValor,
    required this.moraTipo,
    required this.moraValor,
    required this.moraMaxima,
    required this.prolongacionTipo,
    required this.prolongacionValor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Configuracion.fromJson(Map<String, dynamic> json) {
    return Configuracion(
      id: json['id'],
      temaOscuro: json['tema_oscuro'],
      garantiaTipo: TipoValor.fromString(json['garantia_tipo']),
      garantiaValor: (json['garantia_valor'] as num).toDouble(),
      moraTipo: TipoValor.fromString(json['mora_tipo']),
      moraValor: (json['mora_valor'] as num).toDouble(),
      moraMaxima: (json['mora_maxima'] as num).toDouble(),
      prolongacionTipo: TipoValor.fromString(json['prolongacion_tipo']),
      prolongacionValor: (json['prolongacion_valor'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tema_oscuro': temaOscuro,
      'garantia_tipo': garantiaTipo.name,
      'garantia_valor': garantiaValor,
      'mora_tipo': moraTipo.name,
      'mora_valor': moraValor,
      'mora_maxima': moraMaxima,
      'prolongacion_tipo': prolongacionTipo.name,
      'prolongacion_valor': prolongacionValor,
    };
  }

  double calcularGarantia(double monto) {
    if (garantiaTipo == TipoValor.porcentaje) {
      return monto * (garantiaValor / 100);
    }
    return garantiaValor;
  }

  double calcularMora(double monto, int dias) {
    double moraPorDia;
    if (moraTipo == TipoValor.porcentaje) {
      moraPorDia = monto * (moraValor / 100);
    } else {
      moraPorDia = moraValor;
    }

    final moraTotal = moraPorDia * dias;
    return moraTotal > moraMaxima ? moraMaxima : moraTotal;
  }

  double calcularProlongacion(double monto, int dias) {
    if (prolongacionTipo == TipoValor.porcentaje) {
      return monto * (prolongacionValor / 100) * dias;
    }
    return prolongacionValor * dias;
  }
}
