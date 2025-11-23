// TripPlannr/Features/Join/JoinSessionView.swift

import SwiftUI

struct JoinSessionView: View {
    @StateObject var viewModel: JoinSessionViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Details")) {
                    TextField("Your Name", text: $viewModel.name)
                }

                Section(header: Text("Preferences (Optional)")) {
                    Picker("Travel Mode", selection: $viewModel.preferences.travelMode) {
                        Text("Any").tag(TravelMode?.none)
                        ForEach(TravelMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode as TravelMode?)
                        }
                    }
                    
                    Picker("Price Sensitivity", selection: $viewModel.preferences.priceSensitivity) {
                        Text("Any").tag(PriceSensitivity?.none)
                        ForEach(PriceSensitivity.allCases, id: \.self) { price in
                            Text(price.rawValue).tag(price as PriceSensitivity?)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            await viewModel.joinSession()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Join Session")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("Join Trip")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .onChange(of: viewModel.joinedSuccessfully) { joined in
                if joined {
                    dismiss()
                }
            }
            .errorAlert(error: $viewModel.error)
            .animation(.default, value: viewModel.isLoading)
        }
    }
}

struct JoinSessionView_Previews: PreviewProvider {
    static var previews: some View {
        JoinSessionView(viewModel: JoinSessionViewModel(sessionId: "mockSessionId123"))
    }
}
