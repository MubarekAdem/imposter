import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/words.dart';
import '../models/game_round.dart';
import '../models/player.dart';

enum GamePhase { setup, reveal, voting, result }

enum WinningSide { civilians, imposters }

class GameController extends ChangeNotifier {
  static const int minPlayers = 3;
  static const int maxPlayers = 12;

  int playerCount = 4;
  int imposterCount = 1;
  WordMode wordMode = WordMode.random;
  WordLanguage wordLanguage = WordLanguage.english;
  String manualWord = '';
  bool useCustomPlayerNames = false;
  List<String> customPlayerNames = List<String>.filled(4, '');

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

  List<Player> get playersInRound => currentRound?.players ?? <Player>[];

  Map<int, int> get votesByVoter => currentRound?.votes ?? const <int, int>{};

  bool get isVotingComplete =>
      currentRound != null && votesByVoter.length >= playersInRound.length;

  Map<int, int> get voteCounts {
    final Map<int, int> counts = <int, int>{};
    for (final int suspectId in votesByVoter.values) {
      counts[suspectId] = (counts[suspectId] ?? 0) + 1;
    }
    return counts;
  }

  int get highestVoteCount {
    if (voteCounts.isEmpty) {
      return 0;
    }
    return voteCounts.values.reduce((int a, int b) => a > b ? a : b);
  }

  List<int> get topVotedPlayerIds {
    final int maxVotes = highestVoteCount;
    if (maxVotes == 0) {
      return <int>[];
    }

    return voteCounts.entries
        .where((MapEntry<int, int> entry) => entry.value == maxVotes)
        .map((MapEntry<int, int> entry) => entry.key)
        .toList();
  }

  bool get hasTopVoteTie => topVotedPlayerIds.length > 1;

  List<Player> get imposterPlayers =>
      playersInRound.where((Player player) => player.isImposter).toList();

  WinningSide get winningSide {
    if (hasTopVoteTie || topVotedPlayerIds.isEmpty) {
      return WinningSide.imposters;
    }

    final int votedId = topVotedPlayerIds.first;
    final bool votedPlayerIsImposter =
        playersInRound.any((Player player) => player.id == votedId && player.isImposter);

    return votedPlayerIsImposter ? WinningSide.civilians : WinningSide.imposters;
  }

  Player? getPlayerById(int id) {
    for (final Player player in playersInRound) {
      if (player.id == id) {
        return player;
      }
    }
    return null;
  }

  void updatePlayerCount(int value) {
    playerCount = value.clamp(minPlayers, maxPlayers);
    if (imposterCount >= playerCount) {
      imposterCount = playerCount - 1;
    }
    if (customPlayerNames.length < playerCount) {
      customPlayerNames = <String>[
        ...customPlayerNames,
        ...List<String>.filled(playerCount - customPlayerNames.length, ''),
      ];
    } else if (customPlayerNames.length > playerCount) {
      customPlayerNames = customPlayerNames.sublist(0, playerCount);
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

  void updateWordLanguage(WordLanguage language) {
    wordLanguage = language;
    notifyListeners();
  }

  void updateManualWord(String value) {
    manualWord = value;
    notifyListeners();
  }

  void setUseCustomPlayerNames(bool value) {
    useCustomPlayerNames = value;
    notifyListeners();
  }

  void updatePlayerName({required int index, required String value}) {
    if (index < 0 || index >= customPlayerNames.length) {
      return;
    }
    customPlayerNames[index] = value;
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
      final String fallbackName = 'Player $id';
      final String candidateName =
          useCustomPlayerNames ? customPlayerNames[index].trim() : '';
      return Player(
        id: id,
        displayName: candidateName.isEmpty ? fallbackName : candidateName,
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
      votes: const <int, int>{},
    );

    phase = GamePhase.reveal;
    notifyListeners();
    return true;
  }

  void setPhase(GamePhase nextPhase) {
    phase = nextPhase;
    notifyListeners();
  }

  void recordVote({required int voterId, required int suspectId}) {
    if (currentRound == null) {
      return;
    }

    final Map<int, int> updatedVotes = Map<int, int>.from(votesByVoter);
    updatedVotes[voterId] = suspectId;
    currentRound = currentRound!.copyWith(votes: updatedVotes);
    notifyListeners();
  }

  void clearVotes() {
    if (currentRound == null) {
      return;
    }
    currentRound = currentRound!.copyWith(votes: const <int, int>{});
    notifyListeners();
  }

  String _pickRandomWord() {
    final Random random = Random();
    final List<String> sourcePool =
        wordLanguage == WordLanguage.amharic ? kAmharicWordPool : kEnglishWordPool;
    return sourcePool[random.nextInt(sourcePool.length)];
  }
}
