import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/words.dart';
import '../models/game_round.dart';
import '../state/game_controller.dart';
import 'reveal_screen.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  static const String routeName = '/setup';

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();
    final int maxImposters = controller.playerCount - 1;
    final String? validationError = controller.setupValidationError;

    return Scaffold(
      appBar: AppBar(title: const Text('Imposter Setup 🎭')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  '🎮 Round Setup',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set player count, choose imposters, and pick how the word is generated.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '👥 Players: ${controller.playerCount}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        Slider(
                          value: controller.playerCount.toDouble(),
                          min: GameController.minPlayers.toDouble(),
                          max: GameController.maxPlayers.toDouble(),
                          divisions: GameController.maxPlayers - GameController.minPlayers,
                          label: controller.playerCount.toString(),
                          onChanged: (double value) {
                            controller.updatePlayerCount(value.round());
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '🕵️ Imposters: ${controller.imposterCount}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        Slider(
                          value: controller.imposterCount.toDouble(),
                          min: 1,
                          max: maxImposters.toDouble(),
                          divisions: maxImposters - 1,
                          label: controller.imposterCount.toString(),
                          onChanged: (double value) {
                            controller.updateImposterCount(value.round());
                          },
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('✍️ Use custom player names'),
                          subtitle: const Text('Optional: leave any field empty to use default Player N.'),
                          value: controller.useCustomPlayerNames,
                          onChanged: controller.setUseCustomPlayerNames,
                        ),
                        if (controller.useCustomPlayerNames) ...<Widget>[
                          const SizedBox(height: 8),
                          for (int i = 0; i < controller.playerCount; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                key: ValueKey<String>('player_name_$i'),
                                initialValue: controller.customPlayerNames[i],
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Player ${i + 1} Name (Optional)',
                                  prefixIcon: const Icon(Icons.person_rounded),
                                ),
                                onChanged: (String value) {
                                  controller.updatePlayerName(index: i, value: value);
                                },
                              ),
                            ),
                        ],
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
                          '🔐 Word Source',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<WordMode>(
                          segments: const [
                            ButtonSegment<WordMode>(
                              value: WordMode.random,
                              label: Text('Random'),
                            ),
                            ButtonSegment<WordMode>(
                              value: WordMode.manual,
                              label: Text('Manual'),
                            ),
                          ],
                          selected: <WordMode>{controller.wordMode},
                          onSelectionChanged: (Set<WordMode> value) {
                            controller.updateWordMode(value.first);
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '🌐 Random Word Language',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<WordLanguage>(
                          segments: const [
                            ButtonSegment<WordLanguage>(
                              value: WordLanguage.english,
                              label: Text('English'),
                            ),
                            ButtonSegment<WordLanguage>(
                              value: WordLanguage.amharic,
                              label: Text('Amharic'),
                            ),
                          ],
                          selected: <WordLanguage>{controller.wordLanguage},
                          onSelectionChanged: (Set<WordLanguage> value) {
                            controller.updateWordLanguage(value.first);
                          },
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Used when Word Source is Random.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        if (controller.wordMode == WordMode.manual) ...<Widget>[
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: controller.manualWord,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Secret Word',
                              hintText: 'Type the word non-imposters should see',
                            ),
                            onChanged: controller.updateManualWord,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (validationError != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '⚠️ $validationError',
                        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: controller.canStartRound
                      ? () {
                          final bool started = controller.startRound();
                          if (!started) {
                            return;
                          }
                          Navigator.of(context).pushNamed(RevealScreen.routeName);
                        }
                      : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Round'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
