//
//  Copyright (c) 2015 Harry Cheung
//

import UIKit

enum GateType: String, Printable {
  case SPLIT = "SPLIT", START = "START", FINISH = "FINISH", START_FINISH = "START_FINISH"
  
  var description : String {
    switch self {
    case .SPLIT: return "SPLIT"
    case .START: return "START"
    case .FINISH: return "FINISH"
    case .START_FINISH: return "START_FINISH"
    }
  }
}

class Gate: Point {
  
  let LINE_WIDTH:    Double = 30
  let BEARING_RANGE: Double = 5
  
  let type: GateType
  let splitNumber: Int
  var leftPoint, rightPoint: Point?
  
  init(type: GateType, splitNumber: Int, latitude: Double, longitude: Double, bearing: Double) {
    self.type = type
    self.splitNumber = splitNumber
    super.init(latitude: latitude, longitude: longitude, inRadians: false)
    let leftBearing  = bearing - 90 < 0 ? bearing + 270 : bearing - 90
    let rightBearing = bearing + 90 > 360 ? bearing - 270 : bearing + 90
    self.leftPoint  = destination(leftBearing, distance: LINE_WIDTH / 2)
    self.rightPoint = destination(rightBearing, distance: LINE_WIDTH / 2)
    self.bearing = bearing
  }
  
  func crossed(#start: Point, destination: Point) -> Point? {
    let pathBearing = start.bearingTo(destination)
    var cross: Point? = nil
    if pathBearing > (bearing - BEARING_RANGE) &&
      pathBearing < (bearing + BEARING_RANGE) {
      cross = Point.intersectSimple(p: leftPoint!, p2: rightPoint!, q: start, q2: destination)
      if cross != nil {
        let distance      = start.distanceTo(cross!)
        let timeSince     = destination.timestamp - start.timestamp
        let acceleration  = (destination.speed - start.speed) / timeSince
        let timeCross     = Physics.time(distance: distance, velocity: start.speed, acceleration: acceleration)
        cross!.generated   = true
        cross!.speed       = start.speed + acceleration * timeCross
        cross!.bearing     = start.bearingTo(destination)
        cross!.timestamp   = start.timestamp + timeCross
        cross!.lapDistance = start.lapDistance + distance
        cross!.lapTime     = start.lapTime + timeCross
        cross!.splitTime   = start.splitTime + timeCross
      }
    }
    return cross
  }
}
