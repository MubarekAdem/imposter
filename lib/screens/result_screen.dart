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
  static const Color _bgTop = Color(0xFF121C5C);
  static const Color _bgBottom = Color(0xFF090F34);

  static const List<IconData> _avatarIcons = <IconData>[
    Icons.psychology,
    Icons.android,
    Icons.pets,
    Icons.nightlight_round,
    Icons.auto_awesome,
    Icons.rocket_launch,
    Icons.visibility,
    Icons.sports_esports,
    Icons.emoji_people,
    Icons.catching_pokemon,
  ];

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

  Color _avatarColorForSeed(String seed) {
    final int hash = seed.hashCode.abs();
    const List<Color> colors = <Color>[
      Color(0xFF3EC1FF),
      Color(0xFF6EF2B2),
      Color(0xFFFFB86B),
      Color(0xFFE78CFF),
      Color(0xFFFF7F9D),
      Color(0xFF87A6FF),
    ];
    return colors[hash % colors.length];
  }

  IconData _avatarIconForSeed(String seed) {
    final int hash = seed.hashCode.abs();
    return _avatarIcons[hash % _avatarIcons.length];
  }

  Widget _panel({
    required Widget child,
    Color borderColor = const Color(0xFF3958B7),
    Color backgroundColor = const Color(0xFF12276D),
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
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
    final List<Player> civilians =
        players.where((Player player) => !player.isImposter).toList();
    final Map<int, int> voteCounts = controller.voteCounts;
    final List<int> topVotedIds = controller.topVotedPlayerIds;

    final int totalVotes = voteCounts.values.fold<int>(0, (int a, int b) => a + b);
    final Set<int> topVotedSet = topVotedIds.toSet();
    final List<Player> detectedImposters =
        imposters.where((Player p) => topVotedSet.contains(p.id)).toList();

    final bool civiliansWon = winner == WinningSide.civilians;
    final String winnerLabel = civiliansWon ? 'CIVILIANS WIN!' : 'IMPOSTERS WIN!';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[_bgTop, _bgBottom],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2F61FF).withValues(alpha: 0.14),
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF31D3FF).withValues(alpha: 0.12),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    children: [
                      const Text(
                        'GAME RESULTS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _panel(
                        borderColor:
                            civiliansWon ? const Color(0xFF68F7D2) : const Color(0xFFFF7A8A),
                        backgroundColor:
                            civiliansWon ? const Color(0xFF123A5F) : const Color(0xFF421C42),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            winnerLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: civiliansWon
                                  ? const Color(0xFF8DF9DE)
                                  : const Color(0xFFFF9EAA),
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _panel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'SECRET WORD:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF93E1D9),
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedBuilder(
                              animation: _typingController,
                              builder: (BuildContext context, Widget? child) {
                                if (_animatedWord.isEmpty) {
                                  return const Text(
                                    'NO WORD',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFE9F3FF),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  );
                                }

                                final int visibleCount =
                                    (_animatedWord.length * _typingController.value).ceil();
                                final int clampedCount =
                                    visibleCount.clamp(0, _animatedWord.length);
                                final String visibleWord =
                                    _animatedWord.substring(0, clampedCount);
                                final bool done = _typingController.value >= 1;

                                return FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    done
                                        ? visibleWord.toUpperCase()
                                        : '${visibleWord.toUpperCase()}|',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFFFE58D),
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _panel(
                        borderColor: const Color(0xFF9A5C8B),
                        backgroundColor: const Color(0xFF1A255F),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'IMPOSTER DETECTED:',
                              style: TextStyle(
                                color: Color(0xFFFF818B),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (final Player imposter in imposters)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF8D6BDA),
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor:
                                            _avatarColorForSeed(imposter.avatarSeed),
                                        child: Icon(
                                          _avatarIconForSeed(imposter.avatarSeed),
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        imposter.displayName.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      topVotedSet.contains(imposter.id)
                                          ? '1 / 1 😈'
                                          : '0 / 1 😈',
                                      style: const TextStyle(
                                        color: Color(0xFFFFB0B7),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.14),
                                  ),
                                ),
                              ),
                              child: Text(
                                tie
                                    ? 'Tie on top votes -> imposters win by rule.'
                                    : detectedImposters.isEmpty
                                        ? 'No imposter received the top vote.'
                                        : 'Imposter got the top vote.',
                                style: const TextStyle(
                                  color: Color(0xFFC8D6FF),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _panel(
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                            final bool isNarrow = constraints.maxWidth < 420;
                            final double cardWidth =
                                isNarrow ? constraints.maxWidth : (constraints.maxWidth - 8) / 2;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CIVILIAN ROLES (Votes Received):',
                                  style: TextStyle(
                                    color: Color(0xFF8EE8D2),
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  runSpacing: 8,
                                  spacing: 8,
                                  children: civilians.map((Player player) {
                                    final int votes = voteCounts[player.id] ?? 0;
                                    return SizedBox(
                                      width: cardWidth,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.06),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.18),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor:
                                                  _avatarColorForSeed(player.avatarSeed),
                                              child: Icon(
                                                _avatarIconForSeed(player.avatarSeed),
                                                color: Colors.white,
                                                size: 17,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    player.displayName.toUpperCase(),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w900,
                                                    ),
                                                  ),
                                                  Text(
                                                    '($votes vote${votes == 1 ? '' : 's'})',
                                                    style: const TextStyle(
                                                      color: Color(0xFFBFD2FF),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black.withValues(alpha: 0.2),
                                  ),
                                  child: Text(
                                    'TOTAL: ${players.length} PLAYERS • $totalVotes VOTES',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFFFE8A0),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      _panel(
                        backgroundColor: const Color(0xFF102051),
                        borderColor: const Color(0xFF3F67D4),
                        child: Text(
                          outcomeDetail,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFD8E6FF),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          final bool isNarrow = constraints.maxWidth < 430;
                          final List<Widget> buttons = [
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF38A6FF),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                                onPressed: () {
                                  final bool started = controller.startRound();
                                  if (!started) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Cannot start a new round. Check setup values.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.of(context)
                                      .pushReplacementNamed(RevealScreen.routeName);
                                },
                                child: const Text(
                                  'NEW ROUND\n(Same Players & Word)',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2FC65F),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                                onPressed: () {
                                  controller.setPhase(GamePhase.setup);
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    SetupScreen.routeName,
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: const Text(
                                  'NEW SETUP\n(Change Settings)',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ];

                          if (isNarrow) {
                            return Column(
                              children: [
                                SizedBox(width: double.infinity, child: buttons[0]),
                                const SizedBox(height: 10),
                                SizedBox(width: double.infinity, child: buttons[1]),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              buttons[0],
                              const SizedBox(width: 10),
                              buttons[1],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
