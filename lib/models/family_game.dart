import 'package:family_games/logic/standings.dart';

enum GameType {
  sevenWonders,
  other;

  static GameType fromStorage(String raw) {
    return raw == 'seven_wonders' ? GameType.sevenWonders : GameType.other;
  }

  String get storageValue => switch (this) {
    GameType.sevenWonders => 'seven_wonders',
    GameType.other => 'other',
  };
}

enum WonderCategory {
  maravilla,
  monedas,
  rojo,
  azul,
  amarillo,
  verde,
  morado,
}

class GameMember {
  const GameMember({
    required this.id,
    required this.userId,
    required this.email,
  });

  final String id;
  final String userId;
  final String email;

  factory GameMember.fromMap(Map<String, dynamic> map) {
    return GameMember(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      email: (map['email'] as String?) ?? '',
    );
  }
}

class MatchScore {
  const MatchScore({
    required this.userId,
    required this.email,
    required this.points,
    required this.maravilla,
    required this.monedas,
    required this.rojo,
    required this.azul,
    required this.amarillo,
    required this.verde,
    required this.morado,
  });

  final String userId;
  final String email;
  final int points;
  final int maravilla;
  final int monedas;
  final int rojo;
  final int azul;
  final int amarillo;
  final int verde;
  final int morado;

  factory MatchScore.fromMap(Map<String, dynamic> map) {
    return MatchScore(
      userId: map['user_id'] as String,
      email: (map['email'] as String?) ?? '',
      points: _asInt(map['points']),
      maravilla: _asInt(map['maravilla']),
      monedas: _asInt(map['monedas']),
      rojo: _asInt(map['rojo']),
      azul: _asInt(map['azul']),
      amarillo: _asInt(map['amarillo']),
      verde: _asInt(map['verde']),
      morado: _asInt(map['morado']),
    );
  }

  ScoreLine get line => ScoreLine(userId: userId, email: email, points: points);
}

class GameMatch {
  const GameMatch({
    required this.id,
    required this.playedAt,
    required this.scores,
  });

  final String id;
  final DateTime playedAt;
  final List<MatchScore> scores;

  List<PlayerResult> get results =>
      scoreResults([for (final score in scores) score.line]);

  factory GameMatch.fromMap(Map<String, dynamic> map) {
    final rawScores = (map['fg_match_scores'] as List<dynamic>?) ?? const [];
    return GameMatch(
      id: map['id'] as String,
      playedAt: DateTime.parse(map['played_at'] as String),
      scores: [
        for (final row in rawScores)
          MatchScore.fromMap(Map<String, dynamic>.from(row as Map)),
      ],
    );
  }
}

class FamilyGame {
  const FamilyGame({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.createdBy,
    required this.members,
    required this.matches,
  });

  final String id;
  final String name;
  final GameType type;
  final String description;
  final String createdBy;
  final List<GameMember> members;
  final List<GameMatch> matches;

  List<Standing> get standings => buildStandings(
    members: [
      for (final member in members)
        ScoreLine(userId: member.userId, email: member.email, points: 0),
    ],
    matches: [
      for (final match in matches) [for (final score in match.scores) score.line],
    ],
  );

  factory FamilyGame.fromMap(Map<String, dynamic> map) {
    final rawMembers = (map['fg_game_members'] as List<dynamic>?) ?? const [];
    final rawMatches = (map['fg_matches'] as List<dynamic>?) ?? const [];
    final members = [
      for (final row in rawMembers)
        GameMember.fromMap(Map<String, dynamic>.from(row as Map)),
    ]..sort((a, b) => a.email.compareTo(b.email));
    final matches = [
      for (final row in rawMatches)
        GameMatch.fromMap(Map<String, dynamic>.from(row as Map)),
    ]..sort((a, b) {
      final byDate = b.playedAt.compareTo(a.playedAt);
      if (byDate != 0) return byDate;
      return b.id.compareTo(a.id);
    });
    return FamilyGame(
      id: map['id'] as String,
      name: map['name'] as String,
      type: GameType.fromStorage(map['type'] as String),
      description: (map['description'] as String?) ?? '',
      createdBy: map['created_by'] as String,
      members: members,
      matches: matches,
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse('$value') ?? 0;
}
