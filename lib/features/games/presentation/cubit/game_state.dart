import 'package:equatable/equatable.dart';

import '../../domain/entities/family_game.dart';

sealed class GameState extends Equatable {
  const GameState();
}

class GameInitial extends GameState {
  const GameInitial();
  @override
  List<Object?> get props => [];
}

class GameLoading extends GameState {
  const GameLoading();
  @override
  List<Object?> get props => [];
}

class GameLoaded extends GameState {
  final FamilyGame game;

  /// Increments on every successful load so listeners can react to reloads.
  final int revision;
  const GameLoaded(this.game, {this.revision = 0});
  @override
  List<Object?> get props => [game, revision];
}

class GameError extends GameState {
  /// Game shown before the failed refresh, if any.
  final FamilyGame? game;
  const GameError([this.game]);
  @override
  List<Object?> get props => [game];
}
