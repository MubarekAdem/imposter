import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_round.dart';
import '../state/game_controller.dart';
import 'reveal_screen.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  static const String routeName = '/setup';

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();
    final int maxImposters = controller.playerCount - 1;
    final String? validationError = controller.setupValidationError;

    return Scaffold(
      appBar: AppBar(title: const Text('Imposter Setup')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Round Setup',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text('Players: ${controller.playerCount}'),
            Slider(
              value: controller.playerCount.toDouble(),
              min: GameController.minPlayers.toDouble(),
              max: GameController.maxPlayers.toDouble(),
              divisions: GameController.maxPlayers - GameController.minPlayers,
              label: controller.playerCount.toString(),
              onChanged: (double value) {
                controller.updatePlayerCount(value.round());
              },
            ),
            const SizedBox(height: 8),
            Text('Imposters: ${controller.imposterCount}'),
            Slider(
              value: controller.imposterCount.toDouble(),
              min: 1,
              max: maxImposters.toDouble(),
              divisions: maxImposters - 1,
              label: controller.imposterCount.toString(),
              onChanged: (double value) {
                controller.updateImposterCount(value.round());
              },
            ),
            const SizedBox(height: 16),
            SegmentedButton<WordMode>(
              segments: const [
                ButtonSegment<WordMode>(
                  value: WordMode.random,
                  label: Text('Random'),
                ),
                ButtonSegment<WordMode>(
                  value: WordMode.manual,
                  label: Text('Manual'),
                ),
              ],
              selected: <WordMode>{controller.wordMode},
              onSelectionChanged: (Set<WordMode> value) {
                controller.updateWordMode(value.first);
              },
            ),
            if (controller.wordMode == WordMode.manual) ...<Widget>[
              const SizedBox(height: 12),
              TextFormField(
                initialValue: controller.manualWord,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Secret Word',
                  hintText: 'Type the word non-imposters should see',
                ),
                onChanged: controller.updateManualWord,
              ),
            ],
            if (validationError != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                validationError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: controller.canStartRound
                  ? () {
                      final bool started = controller.startRound();
                      if (!started) {
                        return;
                      }
                      Navigator.of(context).pushNamed(RevealScreen.routeName);
                    }
                  : null,
              child: const Text('Start Round'),
            ),
          ],
        ),
      ),
    );
  }
}
