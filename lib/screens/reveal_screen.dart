import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import 'voting_screen.dart';

class RevealScreen extends StatelessWidget {
  const RevealScreen({super.key});

  static const String routeName = '/reveal';

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();
    final int players = controller.currentRound?.playerCount ?? 0;
    final int imposters = controller.currentRound?.imposterCount ?? 0;
    final String word = controller.currentRound?.word ?? 'Not set';

    return Scaffold(
      appBar: AppBar(title: const Text('Reveal Placeholder')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Phase 3 will add turn-by-turn reveal interactions.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text('Players in round: $players'),
            Text('Imposters in round: $imposters'),
            Text('Debug word preview: $word'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                controller.setPhase(GamePhase.voting);
                Navigator.of(context).pushNamed(VotingScreen.routeName);
              },
              child: const Text('Go to Voting Placeholder'),
            ),
          ],
        ),
      ),
    );
  }
}
