import Foundation

public class Calculator: ObservableObject {
  public var alreadyEnteringNewNumber: Bool {
    !pending.isEmpty
  }

  @Published private(set) var pending: String = ""

  @Published private(set) var result = Value.number(0)

  @Published private(set) var operands: Stack<Value> = Stack()

  @Published private(set) var operators: Stack<Operator> = Stack()

  @Published private(set) var lastOperator: String = ""

  let formatter = NumberFormatter()

  public var display: String {
    if !pending.isEmpty {
      return pending.trimmingCharacters(in: .whitespaces)
    }
    if !operands.isEmpty {
      let operandString = operands.top.format(ImperialFormatter.asYardFeetInches)
      return lastOperator.isEmpty ? operandString : "\(operandString) \(lastOperator)"
    }
    return result.format(ImperialFormatter.asYardFeetInches)
  }

  public func clear(_: String) {
    pending = ""
    operands = Stack([.number(0)])
    lastOperator = ""
  }

  public func digit(_ digit: String) {
    handleOperator(lastOperator)
    pending.append(digit)
  }

  public func unit(_ value: String) {
    handleOperator(lastOperator)

    if pending.hasSuffix(" ") {
      pending = String(pending.dropLast(4))
    }
    pending.append(" \(value) ")
  }

  fileprivate func encodePendingValue() {
    if pending.isEmpty { return }
    operands.push(Value.parse(pending))
    pending = ""
  }

  private func evaluate(atLeast precedence: Int) {
    while !operators.isEmpty && operators.top.precedence >= precedence {
      let top = operators.pop()
      let b = operands.pop()
      let a = operands.pop()

      operands.push(top.evaluate(a, b))
    }
  }

  fileprivate func handleOperator(_ op: String) {
    if lastOperator == "" { return }
    let theOperator = Operator.make(op)
    evaluate(atLeast: theOperator.precedence)
    operators.push(theOperator)
    lastOperator = ""
  }

  public func op(_ op: String) {
    encodePendingValue()
    lastOperator = op
  }

  public func enter(_: String) {
    encodePendingValue()
    evaluate(atLeast: 0)
    if !operands.isEmpty {
      result = operands.pop()
    }
    lastOperator = ""
    assert(operands.isEmpty)
    assert(operators.isEmpty)
  }
}
