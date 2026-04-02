import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/player.dart';
import '../state/game_controller.dart';
import 'reveal_screen.dart';
import 'setup_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  static const String routeName = '/result';

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.read<GameController>();
    final List<Player> players = controller.playersInRound;

    if (players.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No active round found. Start from setup.'),
                const SizedBox(height: 12),
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
        ),
      );
    }

    final WinningSide winner = controller.winningSide;
    final bool tie = controller.hasTopVoteTie;
    final List<Player> imposters = controller.imposterPlayers;
    final Map<int, int> voteCounts = controller.voteCounts;
    final List<int> topVotedIds = controller.topVotedPlayerIds;

    String headline;
    if (winner == WinningSide.civilians) {
      headline = 'Civilians Win';
    } else {
      headline = 'Imposters Win';
    }

    String outcomeDetail;
    if (tie) {
      outcomeDetail = 'Top votes tied. By rule, imposters win this round.';
    } else if (topVotedIds.isEmpty) {
      outcomeDetail = 'No votes were submitted.';
    } else {
      final Player? topVoted = controller.getPlayerById(topVotedIds.first);
      outcomeDetail = '${topVoted?.displayName ?? 'Unknown player'} got the most votes.';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Round Result 🏁'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          winner == WinningSide.civilians ? '🎉 $headline' : '😈 $headline',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(outcomeDetail),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🕵️ Imposters',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        for (final Player imposter in imposters) Text(imposter.displayName),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📊 Vote Breakdown',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        if (voteCounts.isEmpty)
                          const Text('No votes submitted.')
                        else
                          for (final Player player in players)
                            Text('${player.displayName}: ${voteCounts[player.id] ?? 0} vote(s)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    final bool started = controller.startRound();
                    if (!started) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot start a new round. Check setup values.')),
                      );
                      return;
                    }

                    Navigator.of(context).pushReplacementNamed(RevealScreen.routeName);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('New Round (Same Settings)'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    controller.setPhase(GamePhase.setup);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      SetupScreen.routeName,
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Reconfigure Round'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
