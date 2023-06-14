@testable import KiltCalc
import XCTest

final class CalculatorTests: XCTestCase {
  private let calc = Calculator()
  private let addOp = Entry.binary(Operator(name: "+", precedence: 3, evaluate: +))
  private let multiplyOp = Entry.binary(Operator(name: "*", precedence: 5, evaluate: *))
  private let divideOp = Entry.binary(Operator(name: "÷", precedence: 5, evaluate: /))
  private let negate = Entry.unary(Operator(name: "plusOrMinus", precedence: 99, evaluate: { a, _ in a.negate() }))

  private func enter(_ digits: String) {
    digits.forEach { c in
      calc.enter(.digit(Int(String(c))!))
    }
  }

  func test_calculatorStartsZero() throws {
    XCTAssertEqual(calc.display, "0")
  }

  func test_displayChangesWhenDigitsAdded() {
    enter("42")
    XCTAssertEqual(calc.display, "42")
  }

  func test_EqualsEvaluatesTheCurrentDisplay() {
    calc.enter(.digit(4))
    calc.enter(.equals)
    calc.enter(.digit(2))
    XCTAssertEqual(calc.display, "2")
  }

  func test_ClearResetsDisplayAndEntering() {
    calc.enter(.digit(4))
    calc.enter(.clear)
    XCTAssertEqual(calc.display, "0")
  }

  func test_EnterEvaluatesPendingString() {
    calc.enter(.digit(0))
    calc.enter(.digit(0))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "0")
  }

  func test_EnterWithoutPendingUsesZero() {
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "0")
  }

  fileprivate func overflowValue(_ calc: Calculator) {
    (1...350).forEach { _ in
      calc.enter(.digit(9))
    }
  }

  func test_ParsingOverflowValueYieldsError() {
    overflowValue(calc)
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "number too big or too small")
  }

  func test_ClearResetsError() {
    overflowValue(calc)
    calc.enter(.equals)

    calc.enter(.clear)
    XCTAssertEqual("0", calc.display)
  }

  func test_InchesCreatesValueWithUnits() {
    calc.enter(.digit(3))
    calc.enter(.unit(.inch))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "3 in")
  }

  func test_InchesCanAccumulate() {
    calc.enter(.digit(3))
    calc.enter(.unit(.inch))
    calc.enter(.digit(6))
    calc.enter(.unit(.inch))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "9 in")
  }

  func test_DigitsAndUnitsMustCorrespond() {
    calc.enter(.digit(3))
    calc.enter(.unit(.inch))
    calc.enter(.digit(6))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "numbers and units don't match")
  }

  func test_NumberPlusNumber() {
    calc.enter(.digit(3))
    calc.enter(addOp)
    calc.enter(.digit(6))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "9")
  }

  func test_NumberPlusInchesIsError() {
    calc.enter(.digit(3))
    calc.enter(addOp)
    calc.enter(.digit(6))
    calc.enter(.unit(.inch))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "error - mixing inches and numbers")
  }

  func test_InchesPlusNumberIsError() {
    calc.enter(.digit(3))
    calc.enter(.unit(.inch))
    calc.enter(addOp)
    calc.enter(.digit(6))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "error - mixing inches and numbers")
  }

  func test_InchesPlusInchesIsInches() {
    calc.enter(.digit(9))
    calc.enter(.unit(.inch))
    calc.enter(addOp)
    calc.enter(.digit(6))
    calc.enter(.unit(.inch))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "15 in")
  }

  func test_OperatorShowsInDisplay() {
    calc.enter(.digit(9))
    calc.enter(addOp)
    XCTAssertEqual(calc.display, "9+")
  }

  func test_LastOperatorWins() {
    calc.enter(.digit(9))
    calc.enter(multiplyOp)
    calc.enter(addOp)
    calc.enter(.digit(3))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "12")
  }

  func test_TrailingBinaryOperatorIsAnError() {
    calc.enter(.digit(9))
    calc.enter(multiplyOp)
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "expression can't end with an operator")
  }

  func test_PlusOrMinusOnNumber() {
    enter("64")
    calc.enter(negate)
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "-64")
  }

  func test_DigitAfterUnaryOpIsPlacedBeforeIt() {
    calc.enter(.digit(6))
    calc.enter(negate)
    calc.enter(.digit(4))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "-64")
  }

  func test_UnitValueThenUnaryOp() {
    calc.enter(.digit(1))
    calc.enter(.unit(.yard))
    enter("27")
    calc.enter(.unit(.inch))
    calc.enter(negate)
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "-63 in")
  }

  func test_DigitAfterUnaryOpOnUnitIsLeftThere() {
    calc.enter(.digit(6))
    calc.enter(.unit(.inch))
    calc.enter(negate)
    calc.enter(.digit(4))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "numbers and units don't match")
  }

  func test_DigitPlusOrMinusAddDigit_ShouldNegateAndAdd() {
    calc.enter(.digit(6))
    calc.enter(negate)
    calc.enter(addOp)
    calc.enter(.digit(4))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "-2")
  }

  func test_PlusOrMinusFirst_IsError() {
    calc.enter(negate)
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "no value found")
  }

  func test_TooManyLeftParends() {
    calc.enter(.leftParend)
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "error - unbalanced parentheses")
  }

  func test_TooManyRightParends() {
    calc.enter(.rightParend)
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "error - unbalanced parentheses")
  }

  func test_DefaultsToDisplayInches() {
    calc.imperialFormat = ImperialFormatter.inches
    enter("63")
    calc.enter(.unit(.inch))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "63 in")
  }

  func test_ChangingUnitDisplay() {
    calc.imperialFormat = ImperialFormatter.yardFeetInches

    enter("63")
    calc.enter(.unit(.inch))
    calc.enter(.equals)
    XCTAssertEqual(calc.display, "1 yd 2 ft 3 in")

    calc.imperialFormat = ImperialFormatter.inches
    XCTAssertEqual(calc.display, "63 in")
  }

  func test_RoundingTo8thsWithNoIntegerPart() {
    calc.enter(.digit(3))
    calc.enter(divideOp)
    calc.enter(.digit(8))
    calc.enter(.equals)

    XCTAssertEqual(calc.display, "3/8")
  }

  func test_RoundingTo8thsWithIntegerPart() {
    enter("25")
    calc.enter(divideOp)
    calc.enter(.digit(8))
    calc.enter(.equals)

    XCTAssertEqual(calc.display, "3·1/8")
  }

  func test_RoundingTo8thsWithNumeratorRoundedTo8() {
    enter("199")
    calc.enter(divideOp)
    enter("100")
    calc.enter(.equals)

    XCTAssertEqual(calc.display, "2⊖")
  }

  func test_RoundingNegativeNumbers() {
    enter("199")
    calc.enter(negate)
    calc.enter(divideOp)
    enter("100")
    calc.enter(.equals)

    XCTAssertEqual(calc.display, "-2⊕")
  }

  func test_RoundingNegativeNumbersSlightlyBig() {
    enter("201")
    calc.enter(negate)
    calc.enter(divideOp)
    enter("100")
    calc.enter(.equals)

    XCTAssertEqual(calc.display, "-2⊖")
  }

  func test_RoundingFractionOnlyNegativeNumbers() {
    enter("99")
    calc.enter(negate)
    calc.enter(divideOp)
    enter("100")
    calc.enter(.equals)

    XCTAssertEqual(calc.display, "-1⊕")
  }

  func test_RoundingTo16thsWithIntegerPart() {
    enter("15")
    calc.enter(divideOp)
    enter("16")
    calc.enter(.equals)

    XCTAssertEqual(calc.display, "15/16")
  }

  func test_RoundingTo16thsWithPlus() {
    enter("154")
    calc.enter(divideOp)
    enter("160")
    calc.enter(.equals)

    XCTAssertEqual(calc.display, "15/16⊕")
  }

  func test_RoundingTo16thsWithMinus() {
    enter("148")
    calc.enter(divideOp)
    enter("160")
    calc.enter(.equals)

    XCTAssertEqual(calc.display, "15/16⊖")
  }
}
