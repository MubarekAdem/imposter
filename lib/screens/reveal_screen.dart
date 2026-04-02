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
  static const Color _bgTop = Color(0xFF131D61);
  static const Color _bgBottom = Color(0xFF0A103A);

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

  Future<void> _toggleFlip(GameController controller, int totalPlayers) async {
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

      if (_hasViewedCurrentTurn) {
        await Future<void>.delayed(const Duration(milliseconds: 220));
        if (!mounted) {
          return;
        }
        _advanceTurn(controller, totalPlayers);
      }
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

  void _advanceTurn(GameController controller, int totalPlayers) {
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

  Widget _buildHiddenFace(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF264EA4), Color(0xFF1B3478)],
        ),
        border: Border.all(color: const Color(0xFF5F8EE8), width: 1.2),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x333DD3FF), blurRadius: 16, spreadRadius: 1),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off_rounded, color: Colors.white, size: 44),
            SizedBox(height: 10),
            Text(
              'SECRET ROLE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 30,
                letterSpacing: 0.6,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap to reveal. Show once, then close.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFD8E7FF), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevealedFace(
    BuildContext context,
    GameController controller,
    Player currentPlayer,
    String secretText,
    int totalPlayers,
  ) {
    final bool isImposter = currentPlayer.isImposter;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isImposter
              ? const <Color>[Color(0xFF324A9A), Color(0xFF2B1D69)]
              : const <Color>[Color(0xFF1C3E8C), Color(0xFF1C456E)],
        ),
        border: Border.all(color: const Color(0xFF72E1FF), width: 1.3),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x334DE4FF), blurRadius: 18, spreadRadius: 1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.masks_rounded, color: Color(0xFFD6E9FF), size: 36),
            const SizedBox(height: 6),
            const Text(
              'SECRET ROLE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 34,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF112459),
                border: Border.all(color: const Color(0xFF6FD4FF), width: 2),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color(0x5537F0FF), blurRadius: 16, spreadRadius: 2),
                ],
              ),
              child: Icon(
                isImposter ? Icons.cruelty_free : Icons.lightbulb_rounded,
                size: 70,
                color: isImposter ? const Color(0xFFFFC66D) : const Color(0xFF6EE2FF),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF10204E),
                border: Border.all(color: const Color(0xFF7AD8FF), width: 1.4),
              ),
              child: Text(
                isImposter ? 'IMPOSTER' : 'PLAYER',
                style: const TextStyle(
                  color: Color(0xFFFFECA6),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              secretText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isImposter
                  ? 'You are the Imposter!\nDo not share this role.'
                  : 'Remember the word and hide it quickly.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD8E7FF),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF2A6DCA),
                foregroundColor: Colors.white,
              ),
              onPressed: () => _toggleFlip(controller, totalPlayers),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
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
        currentPlayer.isImposter ? 'IMPOSTER' : (currentPlayer.assignedWord ?? 'Unknown');

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _bgBottom,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Secret Reveal'),
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
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double maxWidth = constraints.maxWidth > 620 ? 560 : constraints.maxWidth;
                final double cardWidth = maxWidth.clamp(280.0, 560.0);
                final double cardHeight = (cardWidth * 1.25).clamp(340.0, constraints.maxHeight * 0.72);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: cardWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white.withValues(alpha: 0.08),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              'Turn ${_currentPlayerIndex + 1}/${players.length} • ${currentPlayer.displayName}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFE7F1FF),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: _isSecretVisible ? null : () => _toggleFlip(controller, players.length),
                            child: SizedBox(
                              height: cardHeight,
                              width: double.infinity,
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
                                            child: _buildRevealedFace(
                                              context,
                                              controller,
                                              currentPlayer,
                                              secretText,
                                              players.length,
                                            ),
                                          )
                                        : _buildHiddenFace(context),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _isSecretVisible
                                ? 'Tap X to hide and auto-continue.'
                                : (_hasViewedCurrentTurn
                                    ? 'Preparing next turn...'
                                    : 'Tap the card to reveal your secret role.'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFCCE1FF),
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }
}
