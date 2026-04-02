import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/words.dart';
import '../models/game_round.dart';
import '../state/game_controller.dart';
import 'reveal_screen.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  static const String routeName = '/setup';

  static const Color _bgTop = Color(0xFF131D61);
  static const Color _bgBottom = Color(0xFF0A103A);
  static const Color _panel = Color(0xFF142B79);
  static const Color _panelBorder = Color(0xFF3A58B8);
  static const Color _chip = Color(0xFF2B67C8);
  static const Color _chipSelected = Color(0xFF4BD7B0);
  static const Color _textPrimary = Color(0xFFE9F1FF);
  static const Color _textMuted = Color(0xFFAFC4F9);

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text(
          'WORD LIAR',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'GAME SETTINGS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _pillChoice<T>({
    required T value,
    required T selectedValue,
    required String label,
    required VoidCallback onTap,
  }) {
    final bool selected = value == selectedValue;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected ? _chipSelected : _chip,
            boxShadow: selected
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x443AF8D0),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? const Color(0xFF063549) : _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _counterTile({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _counterButton(
              icon: Icons.remove,
              enabled: value > min,
              onTap: () => onChanged(value - 1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 8,
                      activeTrackColor: _chipSelected,
                      inactiveTrackColor: const Color(0xFF1E3178),
                      thumbColor: const Color(0xFF76D2FF),
                      overlayColor: const Color(0x3376D2FF),
                    ),
                    child: Slider(
                      value: value.toDouble(),
                      min: min.toDouble(),
                      max: max.toDouble(),
                      divisions: max - min,
                      onChanged: (double v) => onChanged(v.round()),
                    ),
                  ),
                  Text(
                    '$min-$max',
                    style: const TextStyle(color: _textMuted, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _counterButton(
              icon: Icons.add,
              enabled: value < max,
              onTap: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _counterButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: enabled ? const Color(0xFF2D75D6) : const Color(0xFF263B79),
          border: Border.all(color: const Color(0xFF5DA7FF)),
        ),
        child: Icon(icon, color: enabled ? Colors.white : _textMuted),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();
    final int maxImposters = controller.playerCount - 1;
    final String? validationError = controller.setupValidationError;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: [
                  _header(),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: 'LANGUAGE',
                    child: Row(
                      children: [
                        _pillChoice<WordLanguage>(
                          value: WordLanguage.english,
                          selectedValue: controller.wordLanguage,
                          label: '🇬🇧 ENGLISH (EN)',
                          onTap: () => controller.updateWordLanguage(WordLanguage.english),
                        ),
                        const SizedBox(width: 8),
                        _pillChoice<WordLanguage>(
                          value: WordLanguage.amharic,
                          selectedValue: controller.wordLanguage,
                          label: '🇪🇹 AMHARIC (AM)',
                          onTap: () => controller.updateWordLanguage(WordLanguage.amharic),
                        ),
                      ],
                    ),
                  ),
                  _sectionCard(
                    title: 'WORD SOURCE',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _pillChoice<WordMode>(
                              value: WordMode.random,
                              selectedValue: controller.wordMode,
                              label: 'AUTOMATIC',
                              onTap: () => controller.updateWordMode(WordMode.random),
                            ),
                            const SizedBox(width: 8),
                            _pillChoice<WordMode>(
                              value: WordMode.manual,
                              selectedValue: controller.wordMode,
                              label: 'MANUAL',
                              onTap: () => controller.updateWordMode(WordMode.manual),
                            ),
                          ],
                        ),
                        if (controller.wordMode == WordMode.manual) ...<Widget>[
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const ValueKey<String>('manual_word_input'),
                            initialValue: controller.manualWord,
                            style: const TextStyle(color: _textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Type your secret word...',
                              hintStyle: const TextStyle(color: _textMuted),
                              filled: true,
                              fillColor: const Color(0xFF11235E),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF4765BE)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6FD7FF), width: 2),
                              ),
                            ),
                            onChanged: controller.updateManualWord,
                          ),
                        ],
                      ],
                    ),
                  ),
                  _sectionCard(
                    title: 'PLAYER SETTINGS',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _counterTile(
                          label: '👥 NUMBER OF PLAYERS',
                          value: controller.playerCount,
                          min: GameController.minPlayers,
                          max: GameController.maxPlayers,
                          onChanged: controller.updatePlayerCount,
                        ),
                        const SizedBox(height: 16),
                        _counterTile(
                          label: '😈 NUMBER OF IMPOSTERS',
                          value: controller.imposterCount,
                          min: 1,
                          max: maxImposters,
                          onChanged: controller.updateImposterCount,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFF11235E),
                            border: Border.all(color: const Color(0xFF3D5AB3)),
                          ),
                          child: SwitchListTile.adaptive(
                            value: controller.useCustomPlayerNames,
                            onChanged: controller.setUseCustomPlayerNames,
                            title: const Text(
                              'CUSTOM PLAYER NAMES',
                              style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w800),
                            ),
                            subtitle: const Text(
                              'Optional: blank names fallback to Player N.',
                              style: TextStyle(color: _textMuted),
                            ),
                          ),
                        ),
                        if (controller.useCustomPlayerNames) ...<Widget>[
                          const SizedBox(height: 10),
                          for (int i = 0; i < controller.playerCount; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextFormField(
                                key: ValueKey<int>(i),
                                initialValue: controller.customPlayerNames[i],
                                style: const TextStyle(color: _textPrimary),
                                decoration: InputDecoration(
                                  labelText: 'Player ${i + 1} Name',
                                  labelStyle: const TextStyle(color: _textMuted),
                                  filled: true,
                                  fillColor: const Color(0xFF0E1F55),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF3F5CB5)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF72D7FF), width: 2),
                                  ),
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
                  if (validationError != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF61213A),
                        border: Border.all(color: const Color(0xFFFF6D9C)),
                      ),
                      child: Text(
                        '⚠️ $validationError',
                        style: const TextStyle(color: Color(0xFFFFDBE7), fontWeight: FontWeight.w700),
                      ),
                    ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF40D67B),
                      foregroundColor: const Color(0xFF0B3C2A),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                    ),
                    onPressed: controller.canStartRound
                        ? () {
                            final bool started = controller.startRound();
                            if (!started) {
                              return;
                            }
                            Navigator.of(context).pushNamed(RevealScreen.routeName);
                          }
                        : null,
                    icon: const Icon(Icons.play_arrow_rounded, size: 30),
                    label: const Text('START GAME'),
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
