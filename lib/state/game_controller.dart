import 'package:flutter/foundation.dart';

import '../models/game_round.dart';
import '../models/player.dart';

enum GamePhase { setup, reveal, voting, result }

class GameController extends ChangeNotifier {
  int playerCount = 4;
  int imposterCount = 1;
  WordMode wordMode = WordMode.random;
  String manualWord = '';

  GamePhase phase = GamePhase.setup;
  GameRound? currentRound;

  void updatePlayerCount(int value) {
    playerCount = value;
    if (imposterCount >= playerCount) {
      imposterCount = playerCount - 1;
    }
    notifyListeners();
  }

  void updateImposterCount(int value) {
    imposterCount = value;
    notifyListeners();
  }

  void updateWordMode(WordMode mode) {
    wordMode = mode;
    notifyListeners();
  }

  void updateManualWord(String value) {
    manualWord = value;
    notifyListeners();
  }

  void createScaffoldRound() {
    final List<Player> players = List<Player>.generate(
      playerCount,
      (int index) => Player(id: index + 1, displayName: 'Player ${index + 1}'),
    );

    currentRound = GameRound(
      playerCount: playerCount,
      imposterCount: imposterCount,
      wordMode: wordMode,
      word: wordMode == WordMode.manual ? manualWord.trim() : null,
      players: players,
    );
  }

  void setPhase(GamePhase nextPhase) {
    phase = nextPhase;
    notifyListeners();
  }
}
