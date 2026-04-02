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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Phase 4 will add winner calculation and vote breakdown.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text('Controller phase: ${controller.phase.name}'),
            const SizedBox(height: 24),
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
