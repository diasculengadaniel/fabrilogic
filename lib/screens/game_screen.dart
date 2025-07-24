import 'package:flutter/material.dart';
import '../fabrilang/parser.dart';
import '../fabrilang/model.dart';
import '../fabrilang/executor.dart';
import '../models/problem.dart';
import '../services/problem_loader.dart';

class GameScreen extends StatefulWidget {
  final int level;
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late TextEditingController _codeController;
  late FocusNode _codeFocusNode;
  String _lastProcessedCode = '';
  FabriLangExecutor? executor;
  FabriState? state;
  List<FabriInstruction>? instructions;
  String feedback = '';
  String? error;
  int currentLine = 0;
  Problem? problem;
  bool loading = true;
  bool success = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _codeFocusNode = FocusNode();
    _codeController.addListener(_onCodeChanged);
    _loadProblem();
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    final newCode = _codeController.text;
    if (newCode.endsWith('\n') && newCode != _lastProcessedCode) {
      _lastProcessedCode = newCode;
      _setupExecutor();
    }
  }

  Future<void> _loadProblem() async {
    setState(() {
      loading = true;
    });
    
    try {
      problem = await ProblemLoader.loadLevel(widget.level);
      _setupExecutor();
    } catch (e) {
      setState(() {
        error = 'Erro ao carregar nível: ${e.toString()}';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _setupExecutor() {
    final cursorPosition = _codeController.selection;
    
    setState(() {
      error = null;
      feedback = '';
      success = false;
      
      try {
        instructions = FabriLangParser.parse(_codeController.text);
        state = FabriState(
          memory: List.filled(problem?.memorySlots ?? 2, null),
          inbox: [...(problem?.inputs ?? [])],
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

    if (cursorPosition.isValid) {
      _codeController.selection = cursorPosition;
    }
  }

  void _step() {
    if (executor == null) return;
    
    final cursorPosition = _codeController.selection;
    
    try {
      executor!.step();
      setState(() {
        currentLine = state!.instructionPointer;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }

    if (cursorPosition.isValid) {
      _codeController.selection = cursorPosition;
    }
    
    _checkSuccess();
  }

  void _run() {
    if (executor == null) return;
    
    final cursorPosition = _codeController.selection;
    
    try {
      executor!.run();
      setState(() {
        currentLine = state!.instructionPointer;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }

    if (cursorPosition.isValid) {
      _codeController.selection = cursorPosition;
    }
    
    _checkSuccess();
  }

  void _reset() {
    final cursorPosition = _codeController.selection;
    _setupExecutor();
    if (cursorPosition.isValid) {
      _codeController.selection = cursorPosition;
    }
  }

  void _checkSuccess() {
    if (problem != null && state != null) {
      setState(() {
        success = _outputsMatch(state!.outbox, problem!.expectedOutputs);
      });
    }
  }

  bool _outputsMatch(List<int> outbox, List<int> expected) {
    if (outbox.length != expected.length) return false;
    for (int i = 0; i < outbox.length; i++) {
      if (outbox[i] != expected[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final acc = state?.accumulator;
    final mem = state?.memory ?? [];
    final inbox = state?.inbox ?? [];
    final outbox = state?.outbox ?? [];
    final instrs = instructions ?? [];

    if (loading || problem == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              problem!.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              problem!.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (problem!.hints.isNotEmpty)
              ExpansionTile(
                title: const Text(
                  'Dicas',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                children: problem!.hints
                    .map((e) => ListTile(
                          leading: const Icon(Icons.lightbulb_outline),
                          title: Text(e),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            if (error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Inbox: $inbox'),
                        Text('Outbox: $outbox'),
                        Text('Acumulador: ${acc ?? "null"}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Memória: '),
                        ...List.generate(
                          mem.length,
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Chip(
                              label: Text('[$i]: ${mem[i] ?? "null"}'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Código FabriLang:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.code, size: 16),
                            SizedBox(width: 8),
                            Text('Editor (pressione Enter após cada comando)'),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        child: TextField(
                          controller: _codeController,
                          focusNode: _codeFocusNode,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            hintText: 'Digite seu código aqui...',
                          ),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.history, size: 16),
                        SizedBox(width: 8),
                        Text('Instruções'),
                      ],
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: instrs.length,
                      itemBuilder: (context, idx) {
                        final isCurrent = (idx == currentLine);
                        return Container(
                          color: isCurrent ? Colors.blue[50] : null,
                          child: ListTile(
                            dense: true,
                            leading: Text(
                              '${idx + 1}.',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            title: Text(
                              instrs[idx].runtimeType.toString(),
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Feedback: $feedback'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _run,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Executar Tudo'),
                ),
                ElevatedButton.icon(
                  onPressed: _step,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Próximo Comando'),
                ),
                ElevatedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reiniciar'),
                ),
              ],
            ),
            if (success)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Parabéns! Saída correta!',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
