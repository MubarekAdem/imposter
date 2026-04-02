import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import 'setup_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  static const String routeName = '/result';

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Result Placeholder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phase 1 only: result calculations will be implemented in Phase 4.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text('Controller phase: ${controller.phase.name}'),
            const Spacer(),
            FilledButton(
              onPressed: () {
                controller.setPhase(GamePhase.setup);
                Navigator.of(context).pushNamedAndRemoveUntil(
                  SetupScreen.routeName,
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Back to Setup'),
            ),
          ],
        ),
      ),
    );
  }
}
