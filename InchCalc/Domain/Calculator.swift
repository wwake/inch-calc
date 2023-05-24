import Foundation

public enum Value {
  case error
  case number(NSNumber)
  case unit(NSNumber, NSNumber, NSNumber)
}

public class Calculator: ObservableObject {
  @Published private(set) var alreadyEnteringNewNumber = false

  @Published private(set) var pending: String = ""

  @Published private(set) var value = Value.number(0)

  let formatter = NumberFormatter()

  public var display: String {
    if !pending.isEmpty { return pending }

    switch value {
    case .error:
      return "error"

    case .number(let aNumber):
      return formatter.string(from: aNumber) ?? ""

    case let .unit(theYards, theFeet, theInches):
      let yards = formatter.string(from: theYards) ?? ""
      let feet = formatter.string(from: theFeet) ?? ""
      let inches = formatter.string(from: theInches) ?? ""
      return "\(inches) in"
    }
  }

  public func clear(_: String) {
    pending = ""
    alreadyEnteringNewNumber = false
    value = .number(0)
  }

  public func digit(_ digit: String) {
    if !alreadyEnteringNewNumber {
      pending = ""
      alreadyEnteringNewNumber = true
    }
    pending.append(digit)
  }

  fileprivate func encodePendingValue() {
    guard !pending.isEmpty else { return }

    do {
      let numbers = try pending
        .split(separator: Regex("[a-z]+"))
        .map { formatter.number(from: String($0)) }

      let units = try pending.split(separator: Regex("[0-9]+"))

      pending = ""

      if numbers.contains(nil) {
        value = .error
        return
      }

      if numbers.isEmpty {
        value = Value.error
        return
      }

      if numbers.count > 1 && numbers.count != units.count {
        value = Value.error
        return
      }

      if numbers.count == 1 && units.count == 0 {
        value = .number(numbers[0]!)
      } else {
        var inches = 0.0
        zip(numbers, units).forEach { number, unit in
          if unit == "in" {
            let possibleNumber = number!
            inches += possibleNumber.doubleValue
          }
        }
        value = Value.unit(NSNumber(0), NSNumber(0), NSNumber(value: inches))
      }
    } catch {
      // can't happen if split regexes are legal
    }
  }

  public func enter(_: String) {
    encodePendingValue()
    alreadyEnteringNewNumber = false
  }

  public func unit(_ value: String) {
    pending.append(value)
  }
}
