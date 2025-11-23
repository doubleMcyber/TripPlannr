// TripPlannr/Features/Session/PollViewModel.swift

import Foundation
import Combine

class PollViewModel: ObservableObject {
    @Published var poll: Poll?
    @Published var isLoading: Bool = false
    @Published var error: Error?

    let sessionId: String
    private let firebaseService: FirebaseService
    private var cancellables = Set<AnyCancellable>()
    
    init(sessionId: String, firebaseService: FirebaseService = .shared) {
        self.sessionId = sessionId
        self.firebaseService = firebaseService
        
        setupListener()
    }

    private func setupListener() {
        isLoading = true
        firebaseService.listenForPollUpdates(sessionId: sessionId)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] poll in
                self?.poll = poll
                self?.error = nil // Clear error on successful update
            }
            .store(in: &cancellables)
    }
    
    func vote(optionId: String) async {
        isLoading = true
        error = nil
        
        do {
            _ = try await firebaseService.vote(sessionId: sessionId, optionId: optionId)
            DispatchQueue.main.async {
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
