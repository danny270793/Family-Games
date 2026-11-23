import 'package:equatable/equatable.dart';

import '../../domain/entities/family_game.dart';

sealed class GamesState extends Equatable {
  const GamesState();
}

class GamesInitial extends GamesState {
  const GamesInitial();
  @override
  List<Object?> get props => [];
}

class GamesLoading extends GamesState {
  const GamesLoading();
  @override
  List<Object?> get props => [];
}

class GamesLoaded extends GamesState {
  final List<FamilyGame> games;
  const GamesLoaded(this.games);
  @override
  List<Object?> get props => [games];
}

class GamesError extends GamesState {
  /// Games shown before the failed refresh (kept so the list does not vanish).
  final List<FamilyGame> games;
  const GamesError([this.games = const []]);
  @override
  List<Object?> get props => [games];
}
