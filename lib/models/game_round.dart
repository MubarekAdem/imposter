import 'player.dart';

enum WordMode { manual, random }

class GameRound {
  const GameRound({
    required this.playerCount,
    required this.imposterCount,
    required this.wordMode,
    required this.players,
    this.word,
    this.votes = const <int, int>{},
  });

  final int playerCount;
  final int imposterCount;
  final WordMode wordMode;
  final String? word;
  final List<Player> players;
  final Map<int, int> votes;

  GameRound copyWith({
    int? playerCount,
    int? imposterCount,
    WordMode? wordMode,
    String? word,
    List<Player>? players,
    Map<int, int>? votes,
  }) {
    return GameRound(
      playerCount: playerCount ?? this.playerCount,
      imposterCount: imposterCount ?? this.imposterCount,
      wordMode: wordMode ?? this.wordMode,
      word: word ?? this.word,
      players: players ?? this.players,
      votes: votes ?? this.votes,
    );
  }
}
