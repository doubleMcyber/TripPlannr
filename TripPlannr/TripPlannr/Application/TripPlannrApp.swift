// TripPlannr/TripPlannr/Application/TripPlannrApp.swift

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFunctions

@main
struct TripPlannrApp: App {
    @State private var showJoinSession: Bool = false
    @State private var deepLinkSessionId: String?
    
    init() {
        FirebaseApp.configure()
        // Configure Firebase Functions region if needed
        // Functions.functions().region = "asia-southeast1" 
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .onOpenURL { url in
                    // Example: tripplannr://join?sessionId=YOUR_SESSION_ID
                    if url.host == "join", let sessionId = url.queryParameters?["sessionId"] {
                        self.deepLinkSessionId = sessionId
                        self.showJoinSession = true
                    }
                }
                .sheet(isPresented: $showJoinSession) {
                    if let sessionId = deepLinkSessionId {
                        JoinSessionView(viewModel: JoinSessionViewModel(sessionId: sessionId))
                    }
                }
        }
    }
}

// MARK: - URL Extension for Query Parameters
extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return nil }
        
        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
}