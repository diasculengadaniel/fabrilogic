import 'package:flutter/material.dart';
import '../fabrilang/parser.dart';
import '../fabrilang/model.dart';
import '../fabrilang/executor.dart';

class GameScreen extends StatefulWidget {
  final int level;
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late TextEditingController _codeController;
  FabriLangExecutor? executor;
  FabriState? state;
  List<FabriInstruction>? instructions;
  String feedback = '';
  String? error;
  int currentLine = 0;

  // Exemplo de setup inicial para o nível
  final List<int> initialInbox = [3, 7];
  final int memorySlots = 2;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(
      text: '''
take
copyto 0
take
add 0
drop
halt
''',
    );
    _setupExecutor();
  }

  void _setupExecutor() {
    setState(() {
      error = null;
      feedback = '';
      try {
        instructions = FabriLangParser.parse(_codeController.text);
        state = FabriState(
          memory: List.filled(memorySlots, null),
          inbox: [...initialInbox],
          accumulator: null,
        );
        executor = FabriLangExecutor(
          instructions: instructions!,
          state: state!,
          onFeedback: (msg, s) {
            setState(() {
              feedback = msg;
              currentLine = s.instructionPointer;
            });
          },
        );
      } catch (e) {
        error = e.toString();
      }
    });
  }

  void _step() {
    if (executor == null) return;
    setState(() {
      try {
        executor!.step();
        currentLine = state!.instructionPointer;
        error = null;
      } catch (e) {
        error = e.toString();
      }
    });
  }

  void _run() {
    if (executor == null) return;
    setState(() {
      try {
        executor!.run();
        currentLine = state!.instructionPointer;
        error = null;
      } catch (e) {
        error = e.toString();
      }
    });
  }

  void _reset() {
    _setupExecutor();
  }

  @override
  Widget build(BuildContext context) {
    final acc = state?.accumulator;
    final mem = state?.memory ?? [];
    final inbox = state?.inbox ?? [];
    final outbox = state?.outbox ?? [];
    final instrs = instructions ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Nível ${widget.level}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'Reiniciar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (error != null)
              Container(
                color: Colors.red[100],
                padding: const EdgeInsets.all(8),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Inbox: $inbox'),
                Text('Outbox: $outbox'),
                Text('Acumulador: ${acc ?? "null"}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Memória: '),
                ...List.generate(
                  mem.length,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('[$i]: ${mem[i] ?? "null"}'),
                  ),
                )
              ],
            ),
            const Divider(),
            const Text('Código FabriLang:'),
            SizedBox(
              height: 120,
              child: TextField(
                controller: _codeController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Digite o código FabriLang aqui',
                ),
                style: const TextStyle(fontFamily: 'monospace'),
                onChanged: (_) {
                  _setupExecutor();
                },
              ),
            ),
            const SizedBox(height: 8),
            const Text('Instruções:'),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(maxHeight: 120),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: instrs.length,
                itemBuilder: (context, idx) {
                  final isCurrent = (idx == currentLine);
                  return Container(
                    color: isCurrent ? Colors.lightBlue[100] : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      child: Text(
                        '${idx + 1}. ${instrs[idx].runtimeType.toString()}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text('Feedback: $feedback'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _run,
                  child: const Text('Executar Tudo'),
                ),
                ElevatedButton(
                  onPressed: _step,
                  child: const Text('Próximo Comando'),
                ),
                ElevatedButton(
                  onPressed: _reset,
                  child: const Text('Reiniciar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
