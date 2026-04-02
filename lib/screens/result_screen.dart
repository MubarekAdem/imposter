import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/player.dart';
import '../state/game_controller.dart';
import 'reveal_screen.dart';
import 'setup_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  static const String routeName = '/result';

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _typingController;
  String _animatedWord = '';

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      value: 0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GameController controller = context.read<GameController>();
    final String word = controller.currentRound?.word ?? '';

    if (word != _animatedWord) {
      _animatedWord = word;
      final int durationMs = math.max(700, math.min(2800, word.length * 95));
      _typingController.duration = Duration(milliseconds: durationMs);
      _typingController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

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
                          '🔤 Secret Word',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        AnimatedBuilder(
                          animation: _typingController,
                          builder: (BuildContext context, Widget? child) {
                            if (_animatedWord.isEmpty) {
                              return const Text('No word available.');
                            }

                            final int visibleCount =
                                (_animatedWord.length * _typingController.value).ceil();
                            final int clampedCount = visibleCount.clamp(0, _animatedWord.length);
                            final String visibleWord = _animatedWord.substring(0, clampedCount);
                            final bool done = _typingController.value >= 1;

                            return Text(
                              done ? visibleWord : '$visibleWord|',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            );
                          },
                        ),
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
