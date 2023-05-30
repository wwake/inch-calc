import Foundation

public typealias ImperialFormatterFunction = (NSNumber) -> String

public enum ImperialFormatter {
  static let formatter = NumberFormatter()

  static func asInches(_ theInches: NSNumber) -> String {
    let inches = formatter.string(from: theInches) ?? ""
    return "\(inches) in"
  }

  static func asYardFeetInches(_ theInches: NSNumber) -> String {
    let yfi = [(ImperialUnits.inchesPerYard, "yd"), (ImperialUnits.inchesPerFoot, "ft"), (1, "in")]

    var remaining = theInches.doubleValue

    var partials: [(Double, String)] = []

    yfi.forEach { minorUnitsPerMajor, label in
      let major = floor(remaining / minorUnitsPerMajor)
      remaining -= major * minorUnitsPerMajor

      if major != 0.0 { partials.append((major, label)) }
    }

    if partials.isEmpty { return "0 in" }

    return partials.map { number, label in
      "\(formatter.string(from: NSNumber(value: number)) ?? "") \(label)"
    }
    .joined(separator: " ")
  }
}