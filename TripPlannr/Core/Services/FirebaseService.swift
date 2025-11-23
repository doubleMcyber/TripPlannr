// TripPlannr/Core/Services/FirebaseService.swift

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine
import CoreLocation

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {
        // Initialize Firebase if not already initialized
        // This is typically handled by FirebaseApp.configure() in the AppDelegate or App struct
    }

    // MARK: - Authentication (Placeholder for now)
    func signInAnonymously() async throws -> String {
        let result = try await Auth.auth().signInAnonymously()
        guard let uid = result.user.uid else {
            throw FirebaseServiceError.authenticationFailed
        }
        return uid
    }

    // MARK: - Session Management
    func createSession(category: TripCategory, hostId: String) async throws -> String {
        let session = Session(hostID: hostId, category: category)
        let docRef = try db.collection("sessions").addDocument(from: session)
        return docRef.documentID
    }
    
    func joinSession(sessionId: String, name: String, avatar: String, location: GeoPoint, preferences: Preferences?) async throws -> String {
        let participant = Participant(name: name, avatar: avatar, preferences: preferences, oneTimeLocation: location)
        let docRef = try db.collection("sessions").document(sessionId).collection("participants").addDocument(from: participant)
        return docRef.documentID
    }
    
    // MARK: - Cloud Function Calls
    
    /// Calls the 'generatePlaces' Cloud Function.
    func generatePlaces(sessionId: String) async throws -> String {
        let callable = Functions.functions().httpsCallable("generatePlaces")
        let data = ["sessionId": sessionId]
        let result = try await callable.call(data)
        guard let message = result.data as? [String: Any], let successMessage = message["message"] as? String else {
            throw FirebaseServiceError.cloudFunctionError("Unknown response from generatePlaces.")
        }
        return successMessage
    }

    /// Calls the 'vote' Cloud Function.
    func vote(sessionId: String, optionId: String) async throws -> String {
        let callable = Functions.functions().httpsCallable("vote")
        let data = ["sessionId": sessionId, "optionId": optionId]
        let result = try await callable.call(data)
        guard let message = result.data as? [String: Any], let successMessage = message["message"] as? String else {
            throw FirebaseServiceError.cloudFunctionError("Unknown response from vote.")
        }
        return successMessage
    }
    
    // MARK: - Real-time Updates
    
    func listenForSessionUpdates(sessionId: String) -> AnyPublisher<Session, Error> {
        return db.collection("sessions").document(sessionId)
            .snapshotPublisher()
            .tryMap { documentSnapshot in
                try documentSnapshot.data(as: Session.self)
            }
            .eraseToAnyPublisher()
    }
    
    func listenForParticipantsUpdates(sessionId: String) -> AnyPublisher<[Participant], Error> {
        return db.collection("sessions").document(sessionId).collection("participants")
            .snapshotPublisher()
            .tryMap { querySnapshot in
                try querySnapshot.documents.map { try $0.data(as: Participant.self) }
            }
            .eraseToAnyPublisher()
    }
    
    func listenForPollUpdates(sessionId: String) -> AnyPublisher<Poll, Error> {
        return db.collection("polls").document(sessionId)
            .snapshotPublisher()
            .tryMap { documentSnapshot in
                try documentSnapshot.data(as: Poll.self)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - FirebaseServiceError

enum FirebaseServiceError: Error, LocalizedError {
    case authenticationFailed
    case cloudFunctionError(String)
    case documentNotFound
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Firebase authentication failed."
        case .cloudFunctionError(let message):
            return "Cloud Function Error: \(message)"
        case .documentNotFound:
            return "Document not found in Firestore."
        case .decodingError(let error):
            return "Data decoding error: \(error.localizedDescription)"
        }
    }
}
