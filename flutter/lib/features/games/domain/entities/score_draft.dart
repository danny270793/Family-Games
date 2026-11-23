class ScoreDraft {
  const ScoreDraft({
    required this.userId,
    required this.points,
    this.maravilla = 0,
    this.monedas = 0,
    this.rojo = 0,
    this.azul = 0,
    this.amarillo = 0,
    this.verde = 0,
    this.morado = 0,
  });

  final String userId;
  final int points;
  final int maravilla;
  final int monedas;
  final int rojo;
  final int azul;
  final int amarillo;
  final int verde;
  final int morado;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'points': points,
    'maravilla': maravilla,
    'monedas': monedas,
    'rojo': rojo,
    'azul': azul,
    'amarillo': amarillo,
    'verde': verde,
    'morado': morado,
  };
}
