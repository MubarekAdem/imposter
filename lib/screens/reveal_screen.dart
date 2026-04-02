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

    return Scaffold(
      appBar: AppBar(title: const Text('Reveal Placeholder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phase 1 only: reveal flow will be implemented in Phase 3.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text('Current players: ${controller.currentRound?.playerCount ?? 0}'),
            const Spacer(),
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
