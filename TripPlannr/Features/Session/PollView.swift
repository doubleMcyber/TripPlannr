// TripPlannr/Features/Session/PollView.swift

import SwiftUI

struct PollView: View {
    @StateObject var viewModel: PollViewModel
    @State private var hasVoted: Bool = false // To disable button after voting

    init(sessionId: String) {
        _viewModel = StateObject(wrappedValue: PollViewModel(sessionId: sessionId))
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.poll == nil {
                ProgressView("Loading Poll...")
        .navigationTitle("Poll")
        .onAppear {
            // Check if the current user has already voted
            // This requires knowing the current user's ID
            // For now, hasVoted is reset every time the view appears
            hasVoted = false
        }
        .errorAlert(error: $viewModel.error)
    }
}

struct PollView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PollView(sessionId: "mockSessionId123")
        }
    }
}
