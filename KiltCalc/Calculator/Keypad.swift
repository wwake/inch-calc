public struct Keypad {
  static let backspace = "\u{232B}"
  static let add = "\u{002b}"
  static let subtract = "\u{2212}"
  static let multiply = "\u{00d7}"
  static let divide = "\u{00f7}"
  static let dot = "\u{2022}" // was "\u{22c5}" (middle dot)
  static let plusOrMinus = "\u{00b1}"

  let contents: [[Key]] = [
    [
      Key("C", .clear),
      Key("(", .leftParend),
      Key(")", .rightParend),
      Key("Z", .pleat),
      Key(backspace, .backspace),
    ],
    [
      Key("yd", .unit(.yard)),
      Key("ft", .unit(.foot)),
      Key("in", .unit(.inch)),
      Key(plusOrMinus, .unary(Operator(name: plusOrMinus, precedence: 99, evaluate: { a, _ in a.negate() }))),
      Key(divide, .binary(Operator(name: divide, precedence: 5, evaluate: /))),
    ],
    [
      Key("MC", .memoryClear),
      Key("7", .digit(7)),
      Key("8", .digit(8)),
      Key("9", .digit(9)),
      Key(multiply, .binary(Operator(name: multiply, precedence: 5, evaluate: *))),
    ],
    [
      Key("MR", .memoryRecall),
      Key("4", .digit(4)),
      Key("5", .digit(5)),
      Key("6", .digit(6)),
      Key(subtract, .binary(Operator(name: subtract, precedence: 3, evaluate: -))),
    ],
    [
      Key("M-", .memorySubtract),
      Key("1", .digit(1)),
      Key("2", .digit(2)),
      Key("3", .digit(3)),
      Key(add, .binary(Operator(name: add, precedence: 3, evaluate: +))),
    ],
    [
      Key("M+", .memoryAdd),
      Key("0", .digit(0)),
      Key(dot, .dot),
      Key("/", .slash),
      Key("=", .equals),
    ],
  ]
}
