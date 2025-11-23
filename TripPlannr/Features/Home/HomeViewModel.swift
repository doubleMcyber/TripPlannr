// TripPlannr/Features/Home/HomeViewModel.swift

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var selectedCategory: TripCategory = .noPreference
    @Published var isLoading = false
    @Published var error: Error?
    @Published var sessionId: String?
    
    private let firebaseService: FirebaseService
    
    init(firebaseService: FirebaseService = .shared) {
        self.firebaseService = firebaseService
    }
    
    func createSession() async {
        isLoading = true
        error = nil
        sessionId = nil
        
        do {
            // Authenticate user anonymously if not already signed in
            let userId = try await firebaseService.signInAnonymously()
            
            // Create a new session in Firebase
            let newSessionId = try await firebaseService.createSession(category: selectedCategory, hostId: userId)
            
            DispatchQueue.main.async {
                self.sessionId = newSessionId
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
