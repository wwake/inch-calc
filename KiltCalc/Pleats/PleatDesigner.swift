import Foundation

public class PleatDesigner: ObservableObject {
  private var updateInProgress = false

  @Published public var notes = ""

  public var message: String {
    if gap == nil {
      return "Type Can't Be Determined"
    }
    if gap!.isZero {
      return "Box Pleat"
    } else if gap! < 0 && gap! > -0.5 {
      return "Box Pleat with Overlap"
    } else if gap! <= -0.5 {
      return "Military Box Pleat"
    } else if gap! > 0 && gap! < 0.5 {
      return "Box Pleat with Gap"
    }
    return "Box Pleat with Too-Large Gap"
  }

  public var needsRequiredValues: Bool {
    hipToHipMeasure == nil || sett == nil || settsPerPleat == nil
  }

  fileprivate func establishNonRequiredVariables() {
    if needsRequiredValues {
      pleatWidth = nil
      pleatCount = nil
      return
    }

    updateInProgress = true
    pleatWidth = pleatFabric! / 3
    pleatCount = hipToHipMeasure! / pleatWidth!
    updateInProgress = false
  }

  @Published public var hipToHipMeasure: Double? {
    didSet {
      establishNonRequiredVariables()
    }
  }

  @Published public var sett: Double? {
    didSet {
      establishNonRequiredVariables()
    }
  }

  @Published public var settsPerPleat: Double? = 1.0 {
    didSet {
      establishNonRequiredVariables()
    }
  }

  public var pleatFabric: Double? {
    if needsRequiredValues { return nil }
    return sett! * settsPerPleat!
  }

  @Published public var pleatCount: Double? {
    didSet {
      if needsRequiredValues || pleatCount == nil {
        return
      }

      if !updateInProgress {
        updateInProgress = true
        pleatWidth = hipToHipMeasure! / pleatCount!
        updateInProgress = false
      }
    }
  }

  @Published public var pleatWidth: Double? {
    didSet {
      if needsRequiredValues || pleatWidth == nil {
        return
      }

      if !updateInProgress {
        updateInProgress = true
        pleatCount = hipToHipMeasure! / pleatWidth!
        updateInProgress = false
      }
    }
  }

  public var gap: Double? {
    if needsRequiredValues || pleatWidth == nil { return nil }
    return (3 * pleatWidth! - pleatFabric!) / 2.0
  }

  public var totalFabric: Double? {
    if needsRequiredValues || pleatCount == nil { return nil }
    return pleatFabric! * pleatCount!
  }
}
