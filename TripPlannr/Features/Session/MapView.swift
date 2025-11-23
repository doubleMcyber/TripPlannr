// TripPlannr/Features/Session/MapView.swift

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var viewModel: MapViewModel
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.annotations) { annotation in
            MapMarker(coordinate: annotation.coordinate, tint: annotation.type == .participant ? .blue : .red)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(viewModel: MapViewModel())
    }
}
