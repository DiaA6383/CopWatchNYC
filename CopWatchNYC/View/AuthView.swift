import SwiftUI

struct AuthView: View {
    @State private var currentViewShowing: String = "login" // The current view being shown: "login" or "signup"
    @State private var reportedLocations: [IdentifiablePin] = [] // Array to store reported locations
    @State private var isLoggedIn = false // Flag to track if the user is logged in
    @State private var isSignedUp = false // Flag to track if the user has signed up

    var body: some View {
        if currentViewShowing == "login" {
            // Show the LoginView if the current view is set to "login"
            LogInView(currentShowingView: $currentViewShowing, reportedLocations: $reportedLocations, isLoggedIn: $isLoggedIn)
                .preferredColorScheme(.light) // Set the color scheme to light mode
        } else {
            // Show the SignUpView if the current view is set to "signup"
            SignUpView(currentShowingView: $currentViewShowing, reportedLocations: $reportedLocations, isSignedUp: $isSignedUp)
                .preferredColorScheme(.dark) // Set the color scheme to dark mode
                .transition(.move(edge: .bottom)) // Apply a transition effect when switching views
        }
    }
}
