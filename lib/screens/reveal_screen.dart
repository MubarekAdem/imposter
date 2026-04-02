import 'dart:math' as math;

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

class _RevealScreenState extends State<RevealScreen>
    with SingleTickerProviderStateMixin {
  int _currentPlayerIndex = 0;
  bool _isSecretVisible = false;
  bool _hasViewedCurrentTurn = false;
  late final AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: 0,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _toggleFlip() async {
    if (_flipController.isAnimating) {
      return;
    }

    if (_isSecretVisible) {
      await _flipController.reverse();
      if (!mounted) {
        return;
      }
      setState(() {
        _isSecretVisible = false;
      });
      return;
    }

    await _flipController.forward();
    if (!mounted) {
      return;
    }
    setState(() {
      _isSecretVisible = true;
      _hasViewedCurrentTurn = true;
    });
  }

  void _hideAndContinue(GameController controller, int totalPlayers) {
    if (_isSecretVisible) {
      return;
    }

    final bool isLastPlayer = _currentPlayerIndex >= totalPlayers - 1;
    if (isLastPlayer) {
      controller.setPhase(GamePhase.voting);
      Navigator.of(context).pushReplacementNamed(VotingScreen.routeName);
      return;
    }

    setState(() {
      _currentPlayerIndex += 1;
      _hasViewedCurrentTurn = false;
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
          title: const Text('Secret Reveal 🤫'),
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
                            '🔄 Turn ${_currentPlayerIndex + 1} of ${players.length}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text('${currentPlayer.displayName}, take the phone.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _toggleFlip,
                    child: SizedBox(
                      height: 240,
                      child: AnimatedBuilder(
                        animation: _flipController,
                        builder: (BuildContext context, Widget? child) {
                          final double angle = _flipController.value * math.pi;
                          final bool showBackFace = angle > math.pi / 2;

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            child: showBackFace
                                ? Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()..rotateY(math.pi),
                                    child: Card(
                                      color: currentPlayer.isImposter
                                          ? const Color(0xFFFFF3E0)
                                          : Theme.of(context).colorScheme.secondaryContainer,
                                      child: Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              currentPlayer.isImposter ? '🕵️ Your role' : '📝 Your word',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              secretText,
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text('Tap card again to flip back and hide.'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : Card(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: const Padding(
                                      padding: EdgeInsets.all(18),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '🙈 Secret Hidden',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Tap this card to flip and reveal.',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isSecretVisible)
                    const Text(
                      'Flip the card back before passing the phone.',
                      textAlign: TextAlign.center,
                    )
                  else if (_hasViewedCurrentTurn)
                    FilledButton.icon(
                      onPressed: () => _hideAndContinue(controller, players.length),
                      icon: const Icon(Icons.navigate_next_rounded),
                      label: Text(
                        _currentPlayerIndex == players.length - 1 ? 'Continue to Voting' : 'Next Player',
                      ),
                    )
                  else
                    const Text(
                      'Tap the card to reveal this player secret.',
                      textAlign: TextAlign.center,
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
