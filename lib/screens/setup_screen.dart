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

    return Scaffold(
      appBar: AppBar(title: const Text('Imposter Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phase 1 Scaffold',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text('Players: ${controller.playerCount}'),
            Text('Imposters: ${controller.imposterCount}'),
            const SizedBox(height: 16),
            SegmentedButton<WordMode>(
              segments: const [
                ButtonSegment<WordMode>(
                  value: WordMode.random,
                  label: Text('Random Word'),
                ),
                ButtonSegment<WordMode>(
                  value: WordMode.manual,
                  label: Text('Manual Word'),
                ),
              ],
              selected: <WordMode>{controller.wordMode},
              onSelectionChanged: (Set<WordMode> value) {
                controller.updateWordMode(value.first);
              },
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                controller.createScaffoldRound();
                controller.setPhase(GamePhase.reveal);
                Navigator.of(context).pushNamed(RevealScreen.routeName);
              },
              child: const Text('Continue to Reveal Placeholder'),
            ),
          ],
        ),
      ),
    );
  }
}
