import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/reveal_screen.dart';
import 'screens/result_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/voting_screen.dart';
import 'state/game_controller.dart';

void main() {
  runApp(const ImposterApp());
}

class ImposterApp extends StatelessWidget {
  const ImposterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameController>(
      create: (_) => GameController(),
      child: MaterialApp(
        title: 'Imposter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        initialRoute: SetupScreen.routeName,
        routes: <String, WidgetBuilder>{
          SetupScreen.routeName: (_) => const SetupScreen(),
          RevealScreen.routeName: (_) => const RevealScreen(),
          VotingScreen.routeName: (_) => const VotingScreen(),
          ResultScreen.routeName: (_) => const ResultScreen(),
        },
      ),
    );
  }
}
