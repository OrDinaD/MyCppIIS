import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if isAuthenticated {
                MainNavigationView()
            } else {
                LoginView(isAuthenticated: $isAuthenticated, isLoading: $isLoading)
            }
        }
        .preferredColorScheme(.light) // Следуем Apple HIG для академических приложений
    }
}

#Preview {
    ContentView()
}