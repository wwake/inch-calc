import Foundation

public typealias ImperialFormatterFunction = (Double) -> String

public enum ImperialFormatter {
  static let formatter = NumberFormatter()

  static func formatNumber(_ value: Double) -> String {
    if value.isInfinite {
      return "result too large"
    }
    let result = formatter.string(from: NSNumber(value: value)) ?? ""
    return "\(result)"
  }

  static func asInches(_ inches: Double) -> String {
    "\(formatNumber(inches)) in"
  }

  static func asYardFeetInches(_ inches: Double) -> String {
    let yfi = [(ImperialUnit.inchesPerYard, "yd"), (ImperialUnit.inchesPerFoot, "ft"), (1, "in")]

    let sign = inches < 0 ? "-" : ""
    var remaining = abs(inches)

    var partials: [(Double, String)] = []

    yfi.forEach { minorUnitsPerMajor, label in
      let major = floor(remaining / minorUnitsPerMajor)
      remaining -= major * minorUnitsPerMajor

      if major != 0.0 { partials.append((major, label)) }
    }

    if partials.isEmpty { return "0 in" }

    return partials.map { number, label in
      let numericPart = formatNumber(number)
      return "\(sign)\(numericPart) \(label)"
    }
    .joined(separator: " ")
  }
}
