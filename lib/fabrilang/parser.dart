import 'model.dart';

class FabriLangParser {
  static List<FabriInstruction> parse(String code) {
    final lines = code.split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('//'))
        .toList();
    final instructions = <FabriInstruction>[];

    for (var line in lines) {
      final parts = line.split(RegExp(r'\s+'));
      final cmd = parts[0].toLowerCase();
      switch (cmd) {
        case 'take':
          instructions.add(TakeInstruction());
          break;
        case 'drop':
          instructions.add(DropInstruction());
          break;
        case 'copyto':
          instructions.add(CopyToInstruction(int.parse(parts[1])));
          break;
        case 'copyfrom':
          instructions.add(CopyFromInstruction(int.parse(parts[1])));
          break;
        case 'add':
          instructions.add(AddInstruction(int.parse(parts[1])));
          break;
        case 'sub':
          instructions.add(SubInstruction(int.parse(parts[1])));
          break;
        case 'jump':
          instructions.add(JumpInstruction(parts[1]));
          break;
        case 'jumpifzero':
          instructions.add(JumpIfZeroInstruction(parts[1]));
          break;
        case 'jumpifneg':
          instructions.add(JumpIfNegInstruction(parts[1]));
          break;
        case 'label':
          instructions.add(LabelInstruction(parts[1]));
          break;
        case 'halt':
          instructions.add(HaltInstruction());
          break;
        default:
          throw FabriLangException('Comando desconhecido: $cmd');
      }
    }
    return instructions;
  }
}
