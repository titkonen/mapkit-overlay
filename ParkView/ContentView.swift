import SwiftUI
import MapKit

// MARK: Properties
let park = Park(filename: "MagicMountain")
let mapView = MKMapView(frame: UIScreen.main.bounds)

struct MapView: UIViewRepresentable {
  func makeUIView(context: Context) -> MKMapView {
    let latDelta = park.overlayTopLeftCoordinate.latitude - park.overlayBottomRightCoordinate.latitude

    // Think of a span as a tv size, measure from one corner to another
    let span = MKCoordinateSpan(latitudeDelta: fabs(latDelta), longitudeDelta: 0.0)
    let region = MKCoordinateRegion(center: park.midCoordinate, span: span)

    mapView.region = region
    mapView.delegate = context.coordinator

    return mapView
  }

  func updateUIView(_ uiView: MKMapView, context: Context) {
  }

  // Acts as the MapView delegate
  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView

    init(_ parent: MapView) {
      self.parent = parent
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      
        if overlay is ParkMapOverlay {
          return ParkMapOverlayView(overlay: overlay, overlayImage: UIImage(imageLiteralResourceName: "overlay_park"))
        } else if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = .green
            return lineView
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = .magenta
            return polygonView
        } else if let character = overlay as? Character {
            let circleView = MKCircleRenderer(overlay: character)
            circleView.strokeColor = character.color
            return circleView
        }
        
      return MKOverlayRenderer()
    }
      
    func mapView(_ mapView: MKMapView,viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = AttractionAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
        annotationView.canShowCallout = true
        return annotationView
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}

// MARK: ContentView
struct ContentView: View {
  @State var mapBoundary = false
  @State var mapOverlay = false
  @State var mapPins = false
  @State var mapCharacterLocation = false
  @State var mapRoute = false

  var body: some View {
    NavigationView {
      MapView()
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(leading:
          HStack {
            Button(":Bound:") {
              self.mapBoundary.toggle()
              self.updateMapOverlayViews()
            }
            .foregroundColor(mapBoundary ? .white : .red)
            .background(mapBoundary ? Color.green : Color.clear)

            Button(":Overlay:") {
              self.mapOverlay.toggle()
              self.updateMapOverlayViews()
            }
            .foregroundColor(mapOverlay ? .white : .red)
            .background(mapOverlay ? Color.green : Color.clear)

            Button(":Pins:") {
              self.mapPins.toggle()
              self.updateMapOverlayViews()
            }
            .foregroundColor(mapPins ? .white : .red)
            .background(mapPins ? Color.green : Color.clear)

            Button(":Characters:") {
              self.mapCharacterLocation.toggle()
              self.updateMapOverlayViews()
            }
            .foregroundColor(mapCharacterLocation ? .white : .red)
            .background(mapCharacterLocation ? Color.green : Color.clear)

            Button(":Route:") {
              self.mapRoute.toggle()
              self.updateMapOverlayViews()
            }
            .foregroundColor(mapRoute ? .white : .red)
            .background(mapRoute ? Color.green : Color.clear)
          }
        )
    }
  }

  func addOverlay() {
      let overlay = ParkMapOverlay(park: park)
      mapView.addOverlay(overlay)
  }

  func addAttractionPins() {
      // 1
      guard let attractions = Park.plist("MagicMountainAttractions")
        as? [[String: String]] else { return }

      // 2
      for attraction in attractions {
        let coordinate = Park.parseCoord(dict: attraction, fieldName: "location")
        let title = attraction["name"] ?? ""
        let typeRawValue = Int(attraction["type"] ?? "0") ?? 0
        let type = AttractionType(rawValue: typeRawValue) ?? .misc
        let subtitle = attraction["subtitle"] ?? ""
        // 3
        let annotation = AttractionAnnotation(
          coordinate: coordinate,
          title: title,
          subtitle: subtitle,
          type: type)
        mapView.addAnnotation(annotation)
      }
  }

  func addRoute() {
    // Path Route Drawing
      guard let points = Park.plist("EntranceToGoliathRoute") as? [String] else {
        return
      }
          
      let cgPoints = points.map { NSCoder.cgPoint(for: $0) }
      let coords = cgPoints.map { CLLocationCoordinate2D(
        latitude: CLLocationDegrees($0.x),
        longitude: CLLocationDegrees($0.y))
      }
      let myPolyline = MKPolyline(coordinates: coords, count: coords.count)
          
      mapView.addOverlay(myPolyline)
  }

  func addBoundary() {
      mapView.addOverlay(MKPolygon(coordinates: park.boundary, count: park.boundary.count))
  }

  func addCharacterLocation() {
      mapView.addOverlay(Character(filename: "BatmanLocations", color: .blue))
      mapView.addOverlay(Character(filename: "TazLocations", color: .orange))
      mapView.addOverlay(Character(filename: "TweetyBirdLocations", color: .yellow))
  }

  func updateMapOverlayViews() {
    mapView.removeAnnotations(mapView.annotations)
    mapView.removeOverlays(mapView.overlays)

    if mapBoundary { addBoundary() }
    if mapOverlay { addOverlay() }
    if mapPins { addAttractionPins() }
    if mapCharacterLocation { addCharacterLocation() }
    if mapRoute { addRoute() } // Path route
  }
}
