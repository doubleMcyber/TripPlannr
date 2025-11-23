// TripPlannr/Features/Session/MapViewModel.swift

import Foundation
import MapKit
import Combine
import FirebaseFirestore

class MapViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var annotations: [MapAnnotation] = []
    
    // Initial region around a default location (e.g., San Francisco)
    init() {
        _region = Published(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }
    
    func updateMap(participants: [Participant], places: [TripOption]?) {
        var newAnnotations: [MapAnnotation] = []
        var locations: [CLLocationCoordinate2D] = []
        
        // Add participants to annotations
        for participant in participants {
            if let geoPoint = participant.oneTimeLocation {
                let coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                newAnnotations.append(MapAnnotation(coordinate: coordinate, title: participant.name, type: .participant))
                locations.append(coordinate)
            }
        }
        
        // Add places to annotations
        if let places = places {
            for place in places {
                let coordinate = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                newAnnotations.append(MapAnnotation(coordinate: coordinate, title: place.name, type: .place))
                locations.append(coordinate)
            }
        }
        
        self.annotations = newAnnotations
        
        // Adjust map region to fit all locations
        if !locations.isEmpty {
            self.region = calculateRegion(for: locations)
        }
    }
    
    private func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
              let minLong = longitudes.min(), let maxLong = longitudes.max() else {
            return region // Return current region if no valid coordinates
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLong + maxLong) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5, // Add some padding
            longitudeDelta: (maxLong - minLong) * 1.5 // Add some padding
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}

struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let type: AnnotationType
}

enum AnnotationType {
    case participant
    case place
}
