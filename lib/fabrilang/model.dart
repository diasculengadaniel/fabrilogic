// Representa cada instrução FabriLang
abstract class FabriInstruction {
  String get label; // Opcional: para instruções com labels
}

class TakeInstruction extends FabriInstruction {
  @override
  String get label => '';
}

class DropInstruction extends FabriInstruction {
  @override
  String get label => '';
}

class CopyToInstruction extends FabriInstruction {
  final int slot;
  CopyToInstruction(this.slot);
  @override
  String get label => '';
}

class CopyFromInstruction extends FabriInstruction {
  final int slot;
  CopyFromInstruction(this.slot);
  @override
  String get label => '';
}

class AddInstruction extends FabriInstruction {
  final int slot;
  AddInstruction(this.slot);
  @override
  String get label => '';
}

class SubInstruction extends FabriInstruction {
  final int slot;
  SubInstruction(this.slot);
  @override
  String get label => '';
}

class JumpInstruction extends FabriInstruction {
  final String targetLabel;
  JumpInstruction(this.targetLabel);
  @override
  String get label => '';
}

class JumpIfZeroInstruction extends FabriInstruction {
  final String targetLabel;
  JumpIfZeroInstruction(this.targetLabel);
  @override
  String get label => '';
}

class JumpIfNegInstruction extends FabriInstruction {
  final String targetLabel;
  JumpIfNegInstruction(this.targetLabel);
  @override
  String get label => '';
}

class LabelInstruction extends FabriInstruction {
  final String labelName;
  LabelInstruction(this.labelName);
  @override
  String get label => labelName;
}

class HaltInstruction extends FabriInstruction {
  @override
  String get label => '';
}

// Estado do executor (acumulador, memória, input/output, etc)
class FabriState {
  int? accumulator;
  List<int?> memory;
  List<int> inbox;
  List<int> outbox;
  int instructionPointer = 0;

  FabriState({
    required this.memory,
    required this.inbox,
    this.accumulator,
    List<int>? outbox,
  }) : outbox = outbox ?? [];
}

// Exceções customizadas
class FabriLangException implements Exception {
  final String message;
  FabriLangException(this.message);

  @override
  String toString() => 'FabriLangException: $message';
}
