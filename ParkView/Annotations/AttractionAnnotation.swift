import MapKit

// 1
enum AttractionType: Int {
  case misc = 0
  case ride
  case food
  case firstAid
  
  func image() -> UIImage {
    switch self {
    case .misc:
      return UIImage(imageLiteralResourceName: "star")
    case .ride:
      return UIImage(imageLiteralResourceName: "ride")
    case .food:
      return UIImage(imageLiteralResourceName: "food")
    case .firstAid:
      return UIImage(imageLiteralResourceName: "firstaid")
    }
  }
}

// 2
class AttractionAnnotation: NSObject, MKAnnotation {
  // 3
  let coordinate: CLLocationCoordinate2D
  let title: String?
  let subtitle: String?
  let type: AttractionType
  
  // 4
  init(
    coordinate: CLLocationCoordinate2D,
    title: String,
    subtitle: String,
    type: AttractionType
  ) {
    self.coordinate = coordinate
    self.title = title
    self.subtitle = subtitle
    self.type = type
  }
}
