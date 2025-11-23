// TripPlannr/Features/Home/HomeView.swift

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var showingSession = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Use a material background for a more modern look
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack {
                        Image(systemName: "globe.americas.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.accentColor)
                        
                        Text("TripPlannr")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                        
                        Text("Plan group outings in seconds.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Picker("Category", selection: $viewModel.selectedCategory) {
                            ForEach(TripCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.regularMaterial)
                        .cornerRadius(12)
                        
                        Button(action: {
                            Task {
                                await viewModel.createSession()
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Start a Trip")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(viewModel.isLoading)
                    }
                    
                }
                .padding(30)
            }
            .navigationDestination(isPresented: $showingSession) {
                if let sessionId = viewModel.sessionId {
                    SessionView(sessionId: sessionId)
                }
            }
            .onChange(of: viewModel.sessionId) { newSessionId in
                if newSessionId != nil {
                    showingSession = true
                }
            }
            .errorAlert(error: $viewModel.error)
            .animation(.default, value: viewModel.isLoading)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
