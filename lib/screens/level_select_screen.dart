import 'package:flutter/material.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text('Seleção de Nível'),
        centerTitle: true,
      ),
      body: Center(
        child: GridView.builder(
          padding: const EdgeInsets.all(32),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 32,
            crossAxisSpacing: 32,
            childAspectRatio: 1,
          ),
          itemCount: 6, // Pode ser dinâmico no futuro
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(level: index + 1),
                  ),
                );
              },
              child: Text('${index + 1}'),
            );
          },
        ),
      ),
    );
  }
}
