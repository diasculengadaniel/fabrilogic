import 'model.dart';

typedef FabriFeedback = void Function(String message, FabriState state);

class FabriLangExecutor {
  final List<FabriInstruction> instructions;
  FabriState state;
  final Map<String, int> labelMap = {};

  FabriFeedback? onFeedback;

  FabriLangExecutor({
    required this.instructions,
    required this.state,
    this.onFeedback,
  }) {
    _buildLabelMap();
  }

  void _buildLabelMap() {
    for (int i = 0; i < instructions.length; i++) {
      final instr = instructions[i];
      if (instr is LabelInstruction) {
        labelMap[instr.labelName] = i;
      }
    }
  }

  /// Executa o próximo comando (step)
  bool step() {
    if (state.instructionPointer < 0 ||
        state.instructionPointer >= instructions.length) {
      throw FabriLangException('Instruction pointer fora de alcance');
    }

    final instr = instructions[state.instructionPointer];

    if (instr is TakeInstruction) {
      if (state.inbox.isEmpty) {
        throw FabriLangException('Inbox vazia');
      }
      state.accumulator = state.inbox.removeAt(0);
      onFeedback?.call('Pegou valor do inbox', state);
    } else if (instr is DropInstruction) {
      if (state.accumulator == null) {
        throw FabriLangException('Acumulador vazio ao tentar soltar');
      }
      state.outbox.add(state.accumulator!);
      state.accumulator = null;
      onFeedback?.call('Valor enviado ao outbox', state);
    } else if (instr is CopyToInstruction) {
      if (state.accumulator == null) {
        throw FabriLangException('Acumulador vazio ao copiar');
      }
      if (instr.slot < 0 || instr.slot >= state.memory.length) {
        throw FabriLangException('Slot de memória inválido');
      }
      state.memory[instr.slot] = state.accumulator;
      onFeedback?.call('Copiou valor para memória', state);
    } else if (instr is CopyFromInstruction) {
      if (instr.slot < 0 || instr.slot >= state.memory.length) {
        throw FabriLangException('Slot de memória inválido');
      }
      final value = state.memory[instr.slot];
      if (value == null) {
        throw FabriLangException('Memória vazia no slot ${instr.slot}');
      }
      state.accumulator = value;
      onFeedback?.call('Carregou valor da memória', state);
    } else if (instr is AddInstruction) {
      if (state.accumulator == null) {
        throw FabriLangException('Acumulador vazio ao somar');
      }
      final value = state.memory[instr.slot];
      if (value == null) {
        throw FabriLangException('Memória vazia no slot ${instr.slot}');
      }
      state.accumulator = state.accumulator! + value;
      onFeedback?.call('Somou valor da memória', state);
    } else if (instr is SubInstruction) {
      if (state.accumulator == null) {
        throw FabriLangException('Acumulador vazio ao subtrair');
      }
      final value = state.memory[instr.slot];
      if (value == null) {
        throw FabriLangException('Memória vazia no slot ${instr.slot}');
      }
      state.accumulator = state.accumulator! - value;
      onFeedback?.call('Subtraiu valor da memória', state);
    } else if (instr is JumpInstruction) {
      if (!labelMap.containsKey(instr.targetLabel)) {
        throw FabriLangException('Label não encontrada: ${instr.targetLabel}');
      }
      state.instructionPointer = labelMap[instr.targetLabel]!;
      onFeedback?.call('Jump para label ${instr.targetLabel}', state);
      return true; // evitar auto-incremento
    } else if (instr is JumpIfZeroInstruction) {
      if (state.accumulator == 0) {
        if (!labelMap.containsKey(instr.targetLabel)) {
          throw FabriLangException('Label não encontrada: ${instr.targetLabel}');
        }
        state.instructionPointer = labelMap[instr.targetLabel]!;
        onFeedback?.call('JumpIfZero para ${instr.targetLabel}', state);
        return true; // evitar auto-incremento
      }
      onFeedback?.call('JumpIfZero não saltou', state);
    } else if (instr is JumpIfNegInstruction) {
      if (state.accumulator != null && state.accumulator! < 0) {
        if (!labelMap.containsKey(instr.targetLabel)) {
          throw FabriLangException('Label não encontrada: ${instr.targetLabel}');
        }
        state.instructionPointer = labelMap[instr.targetLabel]!;
        onFeedback?.call('JumpIfNeg para ${instr.targetLabel}', state);
        return true; // evitar auto-incremento
      }
      onFeedback?.call('JumpIfNeg não saltou', state);
    } else if (instr is HaltInstruction) {
      onFeedback?.call('Programa finalizado', state);
      return false; // Parar execução
    } else if (instr is LabelInstruction) {
      // Label: pular para próxima instrução
      onFeedback?.call('Label encontrada: ${instr.labelName}', state);
    } else {
      throw FabriLangException('Instrução não suportada');
    }

    state.instructionPointer++;
    return true;
  }

  /// Executa todas as instruções até Halt ou erro
  void run() {
    while (state.instructionPointer < instructions.length) {
      final continueExec = step();
      if (!continueExec) break;
    }
  }
}
