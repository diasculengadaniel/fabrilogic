import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final int level;
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Exemplo de comandos FabriLang
  final List<String> commands = [
    'take',
    'copyto 0',
    'take',
    'add 0',
    'drop',
    'halt',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nível ${widget.level}'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Nível 1', style: TextStyle(fontSize: 14)),
                Text('Pedido 3: Soma as Entradas', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Container(
                  width: 280,
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(child: Text('Área visual - fábrica')),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Execução'),
                    Container(
                      width: 100,
                      height: 32,
                      color: Colors.grey[300],
                      child: const Center(child: Text('- take')),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Memória'),
                    Container(
                      width: 100,
                      height: 32,
                      color: Colors.grey[300],
                      child: const Center(child: Text('0: null\n1: null')),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 120,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: commands.length,
                itemBuilder: (context, idx) => Text('${idx + 1}. ${commands[idx]}'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Futuro: executar código completo
                  },
                  child: const Text('Executar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Futuro: executar próximo comando
                  },
                  child: const Text('Próximo comando'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
