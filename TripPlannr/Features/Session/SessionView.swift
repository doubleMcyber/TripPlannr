// TripPlannr/Features/Session/SessionView.swift

import SwiftUI
import MapKit

struct SessionView: View {
    @StateObject var viewModel: SessionViewModel
    @State private var isBottomSheetOpen: Bool = true
    
    init(sessionId: String) {
        _viewModel = StateObject(wrappedValue: SessionViewModel(sessionId: sessionId))
    }
    
    var body: some View {
        ZStack {
            // MapView as the background
            MapView(viewModel: viewModel.mapViewModel)
                .edgesIgnoringSafeArea(.all)
            
            // Bottom Sheet for session details
            GeometryReader { geometry in
                BottomSheetView(
                    isOpen: $isBottomSheetOpen,
                    maxHeight: geometry.size.height * 0.7, // 70% of screen height
                    minHeight: geometry.size.height * 0.15 // 15% of screen height
                ) {
                    if viewModel.isLoading && viewModel.session == nil {
                        ProgressView()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage).foregroundColor(.red)
                    } else if let session = viewModel.session {
                        VStack {
                            Text("Category: \(session.category.rawValue)")
                                .font(.headline)
                                .padding()
                            
                            List(viewModel.participants) { participant in
                                HStack {
                                    Text(participant.avatar)
                                    Text(participant.name)
                                }
                            }
                            
                            Spacer()
                            
                            if session.pollState == .gatheringParticipants {
                                Button(action: {
                                    Task {
                                        await viewModel.generatePlaces()
                                    }
                                }) {
                                    Text("Generate Places")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding()
                            } else if session.pollState == .voting {
                                NavigationLink(destination: PollView(sessionId: viewModel.sessionId)) {
                                    Text("View Poll")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding()
                            } else if session.pollState == .completed {
                                if let winningOption = viewModel.poll?.options.max(by: { $0.votes < $1.votes }) {
                                    WinnerView(winningOption: winningOption)
                                } else {
                                    Text("Poll has ended.")
                                }
                            }
                        }
                    } else {
                        Text("Session not found.")
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationTitle("Trip Session")
        .navigationBarTitleDisplayMode(.inline)
        .errorAlert(error: $viewModel.error)
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SessionView(sessionId: "mockSessionId123")
        }
    }
}
