import Foundation

public enum Value {
  case error
  case number(NSNumber)
  case unit(NSNumber)
}

extension Value: CustomStringConvertible {
  public var description: String {
    let formatter = NumberFormatter()

    switch self {
    case .error:
      return "error"

    case .number(let aNumber):
      return formatter.string(from: aNumber) ?? ""

    case let .unit(theInches):
      let inches = formatter.string(from: theInches) ?? ""
      return "\(inches) in"
    }
  }
}
