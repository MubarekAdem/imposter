import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/words.dart';
import '../models/game_round.dart';
import '../models/player.dart';

enum GamePhase { setup, reveal, voting, result }

class GameController extends ChangeNotifier {
  static const int minPlayers = 3;
  static const int maxPlayers = 12;

  int playerCount = 4;
  int imposterCount = 1;
  WordMode wordMode = WordMode.random;
  String manualWord = '';

  GamePhase phase = GamePhase.setup;
  GameRound? currentRound;

  String get trimmedManualWord => manualWord.trim();

  String? get setupValidationError {
    if (playerCount < minPlayers) {
      return 'Players must be at least $minPlayers.';
    }
    if (imposterCount < 1) {
      return 'There must be at least 1 imposter.';
    }
    if (imposterCount >= playerCount) {
      return 'Imposters must be fewer than players.';
    }
    if (wordMode == WordMode.manual && trimmedManualWord.isEmpty) {
      return 'Manual word cannot be empty.';
    }
    return null;
  }

  bool get canStartRound => setupValidationError == null;

  void updatePlayerCount(int value) {
    playerCount = value.clamp(minPlayers, maxPlayers);
    if (imposterCount >= playerCount) {
      imposterCount = playerCount - 1;
    }
    notifyListeners();
  }

  void updateImposterCount(int value) {
    final int maxImposters = playerCount - 1;
    imposterCount = value.clamp(1, maxImposters);
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

  bool startRound() {
    if (!canStartRound) {
      return false;
    }

    final Random random = Random();

    final Set<int> imposterIds = <int>{};
    while (imposterIds.length < imposterCount) {
      imposterIds.add(random.nextInt(playerCount) + 1);
    }

    final String selectedWord =
        wordMode == WordMode.manual ? trimmedManualWord : _pickRandomWord();

    final List<Player> players = List<Player>.generate(playerCount, (int index) {
      final int id = index + 1;
      final bool isImposter = imposterIds.contains(id);
      return Player(
        id: id,
        displayName: 'Player $id',
        isImposter: isImposter,
        assignedWord: isImposter ? null : selectedWord,
      );
    });

    currentRound = GameRound(
      playerCount: playerCount,
      imposterCount: imposterCount,
      wordMode: wordMode,
      word: selectedWord,
      players: players,
    );

    phase = GamePhase.reveal;
    notifyListeners();
    return true;
  }

  void setPhase(GamePhase nextPhase) {
    phase = nextPhase;
    notifyListeners();
  }

  String _pickRandomWord() {
    final Random random = Random();
    return kDefaultWordPool[random.nextInt(kDefaultWordPool.length)];
  }
}
