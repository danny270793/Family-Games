import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/family_game.dart';
import '../../domain/entities/games_exception.dart';
import '../../domain/entities/score_draft.dart';

abstract class GamesRemoteDatasource {
  Future<List<FamilyGame>> listGames();
  Future<FamilyGame> getGame(String id);
  Future<String> createGame({
    required String name,
    required GameType type,
    required String description,
  });
  Future<void> updateGame({
    required String id,
    required String name,
    required GameType type,
    required String description,
  });
  Future<void> deleteGame(String id);
  Future<void> addMember({required String gameId, required String email});
  Future<void> removeMember(String memberId);
  Future<String> saveMatch({
    required String gameId,
    String? matchId,
    required DateTime playedAt,
    required List<ScoreDraft> scores,
  });
  Future<void> deleteMatch(String matchId);
}

class GamesSupabaseDatasource implements GamesRemoteDatasource {
  final SupabaseClient _client;

  const GamesSupabaseDatasource(this._client);

  static const _gameSelect =
      '*, fg_game_members(*), fg_matches(*, fg_match_scores(*))';

  @override
  Future<List<FamilyGame>> listGames() async {
    final rows = await _client
        .from('fg_games')
        .select(_gameSelect)
        .order('created_at', ascending: false);
    return [
      for (final row in rows)
        FamilyGame.fromMap(Map<String, dynamic>.from(row)),
    ];
  }

  @override
  Future<FamilyGame> getGame(String id) async {
    final row = await _client
        .from('fg_games')
        .select(_gameSelect)
        .eq('id', id)
        .single();
    return FamilyGame.fromMap(Map<String, dynamic>.from(row));
  }

  @override
  Future<String> createGame({
    required String name,
    required GameType type,
    required String description,
  }) async {
    final id = await _guard(
      _client.rpc(
        'fg_create_game',
        params: {
          'p_name': name.trim(),
          'p_type': type.storageValue,
          'p_description': description.trim(),
        },
      ),
    );
    return id.toString();
  }

  @override
  Future<void> updateGame({
    required String id,
    required String name,
    required GameType type,
    required String description,
  }) {
    return _guard(
      _client
          .from('fg_games')
          .update({
            'name': name.trim(),
            'type': type.storageValue,
            'description': description.trim(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id),
    );
  }

  @override
  Future<void> deleteGame(String id) {
    return _guard(_client.rpc('fg_delete_game', params: {'p_game_id': id}));
  }

  @override
  Future<void> addMember({required String gameId, required String email}) {
    return _guard(
      _client.rpc(
        'fg_add_member',
        params: {'p_game_id': gameId, 'p_email': email.trim()},
      ),
    );
  }

  @override
  Future<void> removeMember(String memberId) {
    return _guard(
      _client.rpc('fg_remove_member', params: {'p_member_id': memberId}),
    );
  }

  @override
  Future<String> saveMatch({
    required String gameId,
    String? matchId,
    required DateTime playedAt,
    required List<ScoreDraft> scores,
  }) async {
    final id = await _guard(
      _client.rpc(
        'fg_save_match',
        params: {
          'p_match_id': matchId,
          'p_game_id': gameId,
          'p_played_at': _dateOnly(playedAt),
          'p_scores': [for (final score in scores) score.toJson()],
        },
      ),
    );
    return id.toString();
  }

  @override
  Future<void> deleteMatch(String matchId) {
    return _guard(
      _client.rpc('fg_delete_match', params: {'p_match_id': matchId}),
    );
  }

  Future<T> _guard<T>(Future<T> future) async {
    try {
      return await future;
    } on PostgrestException catch (error) {
      throw GamesException(_code(error.message));
    }
  }

  String _code(String message) {
    const codes = [
      'user_not_found',
      'already_member',
      'at_least_two_players',
      'player_not_in_game',
      'not_a_member',
      'name_required',
      'match_not_found',
      'game_not_found',
    ];
    for (final code in codes) {
      if (message.contains(code)) return code;
    }
    if (message.contains('23505') || message.contains('duplicate')) {
      return 'already_member';
    }
    return 'unexpected';
  }

  String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
