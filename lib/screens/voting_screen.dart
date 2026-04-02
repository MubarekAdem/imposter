import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import 'result_screen.dart';

class VotingScreen extends StatelessWidget {
  const VotingScreen({super.key});

  static const String routeName = '/voting';

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Voting Placeholder')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Phase 4 will add voting interactions and tie handling.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text('Controller phase: ${controller.phase.name}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                controller.setPhase(GamePhase.result);
                Navigator.of(context).pushNamed(ResultScreen.routeName);
              },
              child: const Text('Go to Result Placeholder'),
            ),
          ],
        ),
      ),
    );
  }
}
