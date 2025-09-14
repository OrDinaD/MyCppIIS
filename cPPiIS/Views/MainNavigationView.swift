import SwiftUI

struct MainNavigationView: View {
    @State private var selectedTab = 0
    @State private var personalInfo: BSUIRPersonalInfo?
    @State private var isLoading = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Profile Tab
            ProfileView(personalInfo: $personalInfo, isLoading: $isLoading)
                .tabItem {
                    Label("Профиль", systemImage: "person.circle")
                }
                .tag(0)
            
            // Markbook Tab
            MarkbookView()
                .tabItem {
                    Label("Зачетка", systemImage: "book.closed")
                }
                .tag(1)
            
            // Group Tab
            GroupInfoView()
                .tabItem {
                    Label("Группа", systemImage: "person.3")
                }
                .tag(2)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
                .tag(3)
        }
        .onAppear {
            loadPersonalInfo()
        }
    }
    
    private func loadPersonalInfo() {
        isLoading = true
        
        BSUIRAPIBridge.shared().getPersonalInfo { info, error in
            DispatchQueue.main.async {
                isLoading = false
                if let info = info {
                    personalInfo = info
                }
            }
        }
    }
}

#Preview {
    MainNavigationView()
}