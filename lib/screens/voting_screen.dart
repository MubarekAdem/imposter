import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/player.dart';
import '../state/game_controller.dart';
import 'result_screen.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  static const String routeName = '/voting';

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  int _currentVoterIndex = 0;
  int? _selectedSuspectId;

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

  void _submitVote(GameController controller, List<Player> players) {
    final int? suspectId = _selectedSuspectId;
    if (suspectId == null) {
      return;
    }

    final Player currentVoter = players[_currentVoterIndex];
    controller.recordVote(voterId: currentVoter.id, suspectId: suspectId);

    final bool isLastVoter = _currentVoterIndex >= players.length - 1;
    if (isLastVoter) {
      controller.setPhase(GamePhase.result);
      Navigator.of(context).pushReplacementNamed(ResultScreen.routeName);
      return;
    }

    setState(() {
      _currentVoterIndex += 1;
      _selectedSuspectId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.read<GameController>();
    final List<Player> players = controller.playersInRound;

    if (players.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Voting')),
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

    final Player currentVoter = players[_currentVoterIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Word Liar Vote'), automaticallyImplyLeading: false),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF111A59), Color(0xFF0B113E), Color(0xFF090C2B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ROUND VOTE ${_currentVoterIndex + 1}/${players.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${currentVoter.displayName}, choose the imposter.',
                          style: const TextStyle(color: Color(0xFFC8D3FF)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    itemCount: players.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final Player suspect = players[index];
                      final bool selected = _selectedSuspectId == suspect.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSuspectId = suspect.id;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: selected
                                ? const LinearGradient(
                                    colors: <Color>[Color(0xFF2EE7C9), Color(0xFF4895FF)],
                                  )
                                : null,
                            color: selected ? null : Colors.white.withValues(alpha: 0.09),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF8FF5E6)
                                  : Colors.white.withValues(alpha: 0.2),
                              width: selected ? 2 : 1,
                            ),
                            boxShadow: selected
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: const Color(0xFF48D7FF).withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : const <BoxShadow>[],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _avatarColorForSeed(suspect.avatarSeed),
                                ),
                                child: Icon(
                                  _avatarIconForSeed(suspect.avatarSeed),
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                suspect.displayName,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: selected
                                      ? const Color(0xFF0A1A4D).withValues(alpha: 0.5)
                                      : const Color(0xFF223E93),
                                ),
                                child: Text(
                                  selected ? 'SELECTED' : 'VOTE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withValues(alpha: 0.08),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                    ),
                    child: const Text(
                      '🕵️ Discuss and vote who is lying. If top votes tie, imposters win.',
                      style: TextStyle(color: Color(0xFFD7E1FF), fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF35D073),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: _selectedSuspectId == null
                        ? null
                        : () => _submitVote(controller, players),
                    icon: const Icon(Icons.how_to_vote_rounded),
                    label: Text(
                      _currentVoterIndex == players.length - 1
                          ? 'SUBMIT FINAL VOTE'
                          : 'SUBMIT AND NEXT VOTER',
                    ),
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
