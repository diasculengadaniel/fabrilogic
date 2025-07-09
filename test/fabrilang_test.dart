import 'package:flutter_test/flutter_test.dart';
import '../lib/fabrilang/parser.dart';
import '../lib/fabrilang/executor.dart';
import '../lib/fabrilang/model.dart';

void main() {
  group('FabriLang Parser', () {
    test('Parses basic instructions', () {
      const code = '''
        take
        copyto 0
        take
        add 0
        drop
        halt
      ''';
      final instrs = FabriLangParser.parse(code);
      expect(instrs.length, 6);
      expect(instrs[0], isA<TakeInstruction>());
      expect(instrs[1], isA<CopyToInstruction>());
      expect((instrs[1] as CopyToInstruction).slot, 0);
      expect(instrs[2], isA<TakeInstruction>());
      expect(instrs[3], isA<AddInstruction>());
      expect((instrs[3] as AddInstruction).slot, 0);
      expect(instrs[4], isA<DropInstruction>());
      expect(instrs[5], isA<HaltInstruction>());
    });

    test('Parses label and jumps', () {
      const code = '''
        label start
        take
        jump start
      ''';
      final instrs = FabriLangParser.parse(code);
      expect(instrs[0], isA<LabelInstruction>());
      expect((instrs[0] as LabelInstruction).labelName, 'start');
      expect(instrs[1], isA<TakeInstruction>());
      expect(instrs[2], isA<JumpInstruction>());
      expect((instrs[2] as JumpInstruction).targetLabel, 'start');
    });

    test('Throws on unknown command', () {
      const code = 'foo';
      expect(() => FabriLangParser.parse(code), throwsA(isA<FabriLangException>()));
    });
  });

  group('FabriLang Executor', () {
    test('Executes a simple sum', () {
      const code = '''
        take
        copyto 0
        take
        add 0
        drop
        halt
      ''';
      final instrs = FabriLangParser.parse(code);
      final state = FabriState(
        memory: List.generate(2, (_) => null),
        inbox: [4, 5],
      );
      final executor = FabriLangExecutor(instructions: instrs, state: state);
      executor.run();
      expect(state.outbox, [9]);
    });

    test('Jump and label', () {
      const code = '''
        take
        jump skip
        label skip
        drop
        halt
      ''';
      final instrs = FabriLangParser.parse(code);
      final state = FabriState(memory: List.filled(1, null), inbox: [2]);
      final executor = FabriLangExecutor(instructions: instrs, state: state);
      executor.run();
      expect(state.outbox, [2]);
    });

    test('JumpIfZero works', () {
      const code = '''
        take
        jumpifzero done
        drop
        label done
        halt
      ''';
      final instrs = FabriLangParser.parse(code);
      final state = FabriState(memory: List.filled(1, null), inbox: [0]);
      final executor = FabriLangExecutor(instructions: instrs, state: state);
      executor.run();
      // Como o valor é zero, não faz drop
      expect(state.outbox, isEmpty);
    });

    test('Handles memory errors', () {
      const code = 'copyto 2';
      final instrs = FabriLangParser.parse(code);
      final state = FabriState(memory: List.filled(2, null), inbox: [1]);
      final executor = FabriLangExecutor(instructions: instrs, state: state);
      // Vai dar erro pois acumulador está vazio ao tentar copiar
      expect(() => executor.step(), throwsA(isA<FabriLangException>()));
    });
  });
}
