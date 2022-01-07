import MapKit

// 1
class Character: MKCircle {
  // 2
  private var name: String?
  var color: UIColor?
  
  // 3
  convenience init(filename: String, color: UIColor) {
    guard let points = Park.plist(filename) as? [String] else {
      self.init()
      return
    }
    
    let cgPoints = points.map { NSCoder.cgPoint(for: $0) }
    let coords = cgPoints.map {
      CLLocationCoordinate2D(
        latitude: CLLocationDegrees($0.x),
        longitude: CLLocationDegrees($0.y))
    }
    
    let randomCenter = coords[Int.random(in: 0...3)]
    let randomRadius = CLLocationDistance(Int.random(in: 5...39))
    
    self.init(center: randomCenter, radius: randomRadius)
    self.name = filename
    self.color = color
  }
}

