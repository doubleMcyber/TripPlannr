// TripPlannr/Features/Session/WinnerView.swift

import SwiftUI

struct WinnerView: View {
    let winningOption: TripOption
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 We have a winner! 🎉")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(winningOption.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let vibe = winningOption.vibeDescription {
                    Text(vibe)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                if let rating = winningOption.rating {
                    HStack {
                        Text("Rating:")
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Text("Total Votes: \(winningOption.votes)")
                    .font(.headline)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            // In a future version, you could add a button to open the location in Apple Maps
            Button(action: {
                // Open in Maps
            }) {
                Text("Get Directions")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct WinnerView_Previews: PreviewProvider {
    static var previews: some View {
        WinnerView(winningOption: TripOption(
            placeId: "123",
            name: "The Grand Cafe",
            rating: 4.5,
            priceLevel: 2,
            vibeDescription: "A lovely cafe with great coffee.",
            votes: 5,
            coordinate: .init(latitude: 0, longitude: 0)
        ))
    }
}
