import 'package:flutter/material.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'FrabiLogic',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LevelSelectScreen()),
                  );
                },
                child: const Text('Iniciar Jogo'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                child: const Text('Configurações'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  // Em breve: Tela de Ajuda
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Ajuda'),
                      content: Text('Ajuda em desenvolvimento.'),
                    ),
                  );
                },
                child: const Text('Ajuda'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
