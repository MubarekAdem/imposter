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
  static const Color _bgTop = Color(0xFF131D61);
  static const Color _bgBottom = Color(0xFF0A103A);

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
      backgroundColor: _bgBottom,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Round Result'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          winner == WinningSide.civilians ? '🎉 $headline' : '😈 $headline',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Round Outcome',
                          style: TextStyle(color: Color(0xFFAFC4F9), fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          outcomeDetail,
                          style: const TextStyle(color: Color(0xFFE5EEFF), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF142B79),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF3A58B8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🕵️ Imposters',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        for (final Player imposter in imposters)
                          Text(
                            imposter.displayName,
                            style: const TextStyle(color: Color(0xFFDCE8FF), fontWeight: FontWeight.w700),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF142B79),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF3A58B8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🔤 Secret Word',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        AnimatedBuilder(
                          animation: _typingController,
                          builder: (BuildContext context, Widget? child) {
                            if (_animatedWord.isEmpty) {
                              return const Text(
                                'No word available.',
                                style: TextStyle(color: Color(0xFFD1DFFF)),
                              );
                            }

                            final int visibleCount =
                                (_animatedWord.length * _typingController.value).ceil();
                            final int clampedCount = visibleCount.clamp(0, _animatedWord.length);
                            final String visibleWord = _animatedWord.substring(0, clampedCount);
                            final bool done = _typingController.value >= 1;

                            return Text(
                              done ? visibleWord : '$visibleWord|',
                              style: const TextStyle(
                                color: Color(0xFFFFF1A6),
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF142B79),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF3A58B8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📊 Vote Breakdown',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        if (voteCounts.isEmpty)
                          const Text(
                            'No votes submitted.',
                            style: TextStyle(color: Color(0xFFD1DFFF)),
                          )
                        else
                          for (final Player player in players)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '${player.displayName}: ${voteCounts[player.id] ?? 0} vote(s)',
                                style: const TextStyle(
                                  color: Color(0xFFE3ECFF),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF40D67B),
                      foregroundColor: const Color(0xFF0B3C2A),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
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
                    label: const Text('NEW ROUND (SAME SETTINGS)'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFCFE1FF),
                      side: const BorderSide(color: Color(0xFF4A6AC5)),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      controller.setPhase(GamePhase.setup);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        SetupScreen.routeName,
                        (Route<dynamic> route) => false,
                      );
                    },
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('RECONFIGURE ROUND'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
