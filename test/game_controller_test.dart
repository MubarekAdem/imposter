import 'package:flutter_test/flutter_test.dart';
import 'package:imposter/models/game_round.dart';
import 'package:imposter/state/game_controller.dart';

void main() {
  group('GameController setup validation', () {
    test('manual mode requires non-empty word', () {
      final GameController controller = GameController();

      controller.updateWordMode(WordMode.manual);
      controller.updateManualWord('   ');

      expect(controller.canStartRound, isFalse);
      expect(controller.setupValidationError, 'Manual word cannot be empty.');
    });

    test('imposter count is clamped below player count', () {
      final GameController controller = GameController();

      controller.updatePlayerCount(5);
      controller.updateImposterCount(10);

      expect(controller.imposterCount, 4);
    });
  });

  group('GameController phase and results', () {
    test('startRound builds players and enters reveal phase', () {
      final GameController controller = GameController();

      controller.updatePlayerCount(6);
      controller.updateImposterCount(2);
      final bool started = controller.startRound();

      expect(started, isTrue);
      expect(controller.phase, GamePhase.reveal);
      expect(controller.currentRound, isNotNull);
      expect(controller.playersInRound.length, 6);
      expect(controller.imposterPlayers.length, 2);
    });

    test('top-vote tie makes imposters win', () {
      final GameController controller = GameController();

      controller.updatePlayerCount(4);
      controller.updateImposterCount(1);
      controller.updateWordMode(WordMode.manual);
      controller.updateManualWord('Ocean');
      expect(controller.startRound(), isTrue);

      controller.recordVote(voterId: 1, suspectId: 1);
      controller.recordVote(voterId: 2, suspectId: 2);
      controller.recordVote(voterId: 3, suspectId: 1);
      controller.recordVote(voterId: 4, suspectId: 2);

      expect(controller.hasTopVoteTie, isTrue);
      expect(controller.winningSide, WinningSide.imposters);
    });

    test('new round resets votes and keeps settings', () {
      final GameController controller = GameController();

      controller.updatePlayerCount(5);
      controller.updateImposterCount(2);
      controller.updateWordMode(WordMode.manual);
      controller.updateManualWord('Banana');
      expect(controller.startRound(), isTrue);

      controller.recordVote(voterId: 1, suspectId: 2);
      controller.recordVote(voterId: 2, suspectId: 3);
      expect(controller.votesByVoter, isNotEmpty);

      expect(controller.startRound(), isTrue);
      expect(controller.currentRound, isNotNull);
      expect(controller.currentRound!.playerCount, 5);
      expect(controller.currentRound!.imposterCount, 2);
      expect(controller.currentRound!.wordMode, WordMode.manual);
      expect(controller.currentRound!.word, 'Banana');
      expect(controller.votesByVoter, isEmpty);
    });
  });
}
