import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/player.dart';
import '../state/game_controller.dart';
import 'voting_screen.dart';

class RevealScreen extends StatefulWidget {
  const RevealScreen({super.key});

  static const String routeName = '/reveal';

  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen> {
  int _currentPlayerIndex = 0;
  bool _isSecretVisible = false;

  void _revealSecret() {
    setState(() {
      _isSecretVisible = true;
    });
  }

  void _hideAndContinue(GameController controller, int totalPlayers) {
    final bool isLastPlayer = _currentPlayerIndex >= totalPlayers - 1;
    if (isLastPlayer) {
      controller.setPhase(GamePhase.voting);
      Navigator.of(context).pushReplacementNamed(VotingScreen.routeName);
      return;
    }

    setState(() {
      _isSecretVisible = false;
      _currentPlayerIndex += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.read<GameController>();
    final List<Player> players = controller.currentRound?.players ?? <Player>[];

    if (players.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reveal')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No active round found. Start a round from setup.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    controller.setPhase(GamePhase.setup);
                    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                  },
                  child: const Text('Back to Setup'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final Player currentPlayer = players[_currentPlayerIndex];
    final String secretText =
        currentPlayer.isImposter ? 'You are the IMPOSTER' : (currentPlayer.assignedWord ?? 'Unknown');

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Secret Reveal'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Turn ${_currentPlayerIndex + 1} of ${players.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                '${currentPlayer.displayName}, take the phone.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: _isSecretVisible
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentPlayer.isImposter ? 'Role' : 'Your word',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            secretText,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          const Text('Hide this screen before passing the phone.'),
                        ],
                      )
                    : const Text(
                        'Secret is hidden. Tap reveal only when this player is ready.',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 24),
              if (!_isSecretVisible)
                FilledButton(
                  onPressed: _revealSecret,
                  child: const Text('Tap to Reveal Secret'),
                )
              else
                FilledButton(
                  onPressed: () => _hideAndContinue(controller, players.length),
                  child: Text(
                    _currentPlayerIndex == players.length - 1
                        ? 'Hide and Continue to Voting'
                        : 'Hide and Next Player',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
