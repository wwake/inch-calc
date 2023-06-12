public class Expression {
  var input: InputBuffer
  var operands: Stack<Value> = Stack()
  var operators: Stack<Operator> = Stack()

  init(_ input: InputBuffer) {
    self.input = input
  }

  fileprivate func evaluateAtLeast(_ precedence: Int) {
    while !operators.isEmpty && operators.top.precedence >= precedence {
      let top = operators.pop()
      let b = operands.pop()
      let a = operands.pop()

      operands.push(top.evaluate(a, b))
    }
  }

  fileprivate func evaluateUnary(_ unaryOp: Operator) {
    let a = operands.pop()
    operands.push(unaryOp.evaluate(a, .error("Unary op has no second argument")))
  }

  public func evaluate() -> Value {
    if input.isEmpty { return Value.number(0) }

    var pending = ""

    input.forEach { entry in
      switch entry {
      case .digit, .unit:
        pending.append(entry.description)

      case .unary(let theOperator):
        operands.push(Value.parse(pending))
        pending = ""
        evaluateUnary(theOperator)

      case .binary(let theOperator):
        if !pending.isEmpty {
          operands.push(Value.parse(pending))
        }
        pending = ""

        evaluateAtLeast(theOperator.precedence)
        operators.push(theOperator)

      case .leftParend:
        operators.push(Operator(name: "(", precedence: 0, evaluate: { a, _ in a }))

      case .rightParend:
        if !pending.isEmpty {
          operands.push(Value.parse(pending))
        }
        pending = ""

        evaluateAtLeast(1)

        if operators.isEmpty {
          operands.clear()
          operands.push(.error("error - unbalanced parentheses"))
        } else {
          _ = operators.pop()
        }

      default:
        break
      }
    }

    if !pending.isEmpty {
      operands.push(Value.parse(pending))
    }

    evaluateAtLeast(1)

    if operators.count != 0 {
      return .error("error - unbalanced parentheses")
    }

    if operands.count != 1 {
      return .error("error - unbalanced parentheses")
    }
    return operands.pop()
  }
}
