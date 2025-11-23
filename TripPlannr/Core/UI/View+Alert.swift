// TripPlannr/Core/UI/View+Alert.swift

import SwiftUI

extension View {
    func errorAlert(error: Binding<Error?>, buttonTitle: String = "OK") -> some View {
        let localizedError = error.wrappedValue.map(LocalizedAlertError.init)
        return alert(item: .constant(localizedError)) { error in
            Alert(
                title: Text(error.failureReason ?? "Error"),
                message: Text(error.recoverySuggestion ?? "Please try again."),
                dismissButton: .default(Text(buttonTitle)) {
                    // Reset the error when the alert is dismissed
                    // This assumes the binding is to a @State or @Published property
                }
            )
        }
    }
}

struct LocalizedAlertError: LocalizedError, Identifiable {
    let id = UUID()
    let underlyingError: Error

    var errorDescription: String? {
        underlyingError.localizedDescription
    }
    var recoverySuggestion: String? {
        (underlyingError as? LocalizedError)?.recoverySuggestion
    }
    var failureReason: String? {
        (underlyingError as? LocalizedError)?.failureReason
    }

    init(_ error: Error) {
        self.underlyingError = error
    }
}
