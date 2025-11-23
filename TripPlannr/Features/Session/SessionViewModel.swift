// TripPlannr/Features/Session/SessionViewModel.swift

import Foundation
import Combine
import FirebaseFirestore

class SessionViewModel: ObservableObject {
    @Published var session: Session?
    @Published var participants: [Participant] = []
    @Published var poll: Poll?
    @Published var mapViewModel = MapViewModel()
    @Published var isLoading: Bool = false
    @Published var error: Error?
    // ...
    private func handleCompletion(completion: Subscribers.Completion<Error>) {
        if case .failure(let error) = completion {
            self.error = error
        }
        self.isLoading = false
    }
    // ...
    func generatePlaces() async {
        isLoading = true
        error = nil
        do {
            _ = try await firebaseService.generatePlaces(sessionId: sessionId)
        } catch {
            DispatchQueue.main.async {
                self.error = error
                self.isLoading = false
            }
        }
    }
}

