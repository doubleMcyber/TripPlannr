import Foundation
import FirebaseFirestoreSwift
import CoreLocation
import FirebaseFirestore // Import FirebaseFirestore for GeoPoint

// MARK: - Session Model

struct Session: Identifiable, Codable {
    @DocumentID var id: String?
    let hostID: String
    let timestamp: Date
    var category: TripCategory
    var participants: [Participant] = []
    var options: [TripOption]?
    var pollState: PollState

    // Initializer for creating a new session
    init(hostID: String, category: TripCategory, participants: [Participant] = [], options: [TripOption]? = nil, pollState: PollState = .gatheringParticipants) {
        self.hostID = hostID
        self.timestamp = Date()
        self.category = category
        self.participants = participants
        self.options = options
        self.pollState = pollState
    }
}

// MARK: - Participant Model

struct Participant: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID for the participant
    let name: String
    var avatar: String // URL or name of avatar image
    var preferences: Preferences?
    var oneTimeLocation: FirebaseFirestore.GeoPoint? // Firebase GeoPoint for location

    // Initializer for creating a new participant
    init(name: String, avatar: String, preferences: Preferences? = nil, oneTimeLocation: FirebaseFirestore.GeoPoint? = nil) {
        self.name = name
        self.avatar = avatar
        self.preferences = preferences
        self.oneTimeLocation = oneTimeLocation
    }
}

// MARK: - Supporting Enums and Structs

enum TripCategory: String, Codable, CaseIterable {
    case food = "Food"
    case drinks = "Drinks"
    case coffeeTea = "Coffee/Tea"
    case dessert = "Dessert"
    case scenicSpot = "Scenic Spot"
    case noPreference = "No Preference"
}

enum PollState: String, Codable {
    case gatheringParticipants = "Gathering Participants"
    case generatingOptions = "Generating Options"
    case voting = "Voting"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

struct Preferences: Codable {
    var activityType: String?
    var diet: String?
    var priceSensitivity: PriceSensitivity?
    var travelMode: TravelMode?
}

enum PriceSensitivity: String, Codable, CaseIterable {
    case low = "$"
    case medium = "$$"
    case high = "$$$"
    case veryHigh = "$$$$"
}

enum TravelMode: String, Codable, CaseIterable {
    case walk = "Walk"
    case drive = "Drive"
    case uber = "Uber/Taxi"
    // Add other modes as needed
}

struct TripOption: Identifiable, Codable {
    var id: String { placeId } // Conform to Identifiable using placeId
    let placeId: String
    let name: String
    let rating: Double?
    let priceLevel: Int?
    let vibeDescription: String?
    var votes: Int
    let coordinate: FirebaseFirestore.GeoPoint
    
    // Custom coding keys to handle 'placeId' from Firestore
    enum CodingKeys: String, CodingKey {
        case placeId
        case name
        case rating
        case priceLevel
        case vibeDescription
        case votes
        case coordinate
    }
}

struct Poll: Identifiable, Codable {
    @DocumentID var id: String?
    var options: [TripOption]
    var voters: [String] // Array of user IDs who have voted
}

