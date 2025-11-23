// TripPlannr/Features/Join/JoinSessionViewModel.swift

import Foundation
import Combine
import CoreLocation
import FirebaseFirestore

class JoinSessionViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var joinedSuccessfully: Bool = false
    @Published var preferences: Preferences = Preferences()
    
    private let locationService = LocationService()
    
    private let firebaseService: FirebaseService
    private let sessionId: String
    
    init(sessionId: String, firebaseService: FirebaseService = .shared) {
        self.sessionId = sessionId
        self.firebaseService = firebaseService
        self.locationService.requestLocation()
    }

    private func generateRandomAvatar() -> String {
        let emojis = ["🥳", "😎", "🤩", "🚀", "🎉", "🤠", "🦄"]
        return emojis.randomElement() ?? "🙂"
    }

    func joinSession() async {
        isLoading = true
        error = nil
        
        guard !name.isEmpty else {
            error = NSError(domain: "TripPlannr", code: 400, userInfo: [NSLocalizedDescriptionKey: "Please enter your name."])
            isLoading = false
            return
        }
        
        guard let location = locationService.location else {
            error = NSError(domain: "TripPlannr", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not determine your location. Please ensure location services are enabled."])
            isLoading = false
            return
        }
        
        let geoPoint = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        do {
            let avatar = generateRandomAvatar()
            
            _ = try await firebaseService.joinSession(
                sessionId: sessionId,
                name: name,
                avatar: avatar,
                location: geoPoint,
                preferences: preferences
            )
            
            DispatchQueue.main.async {
                self.joinedSuccessfully = true
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.error = error
                self.isLoading = false
            }
        }
    }
}
