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
      appBar: AppBar(
        title: const Text('Voting'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Voter ${_currentVoterIndex + 1} of ${players.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text('${currentVoter.displayName}, choose who you suspect.'),
            const SizedBox(height: 16),
            for (final Player suspect in players)
              RadioListTile<int>(
                value: suspect.id,
                groupValue: _selectedSuspectId,
                title: Text(suspect.displayName),
                subtitle: Text('Vote for ${suspect.displayName}'),
                onChanged: (int? value) {
                  setState(() {
                    _selectedSuspectId = value;
                  });
                },
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _selectedSuspectId == null
                  ? null
                  : () => _submitVote(controller, players),
              child: Text(
                _currentVoterIndex == players.length - 1 ? 'Submit Final Vote' : 'Submit and Next Voter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
