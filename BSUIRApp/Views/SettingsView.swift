import SwiftUI

struct SettingsView: View {
    @State private var showingLogoutAlert = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // Account Section
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Аккаунт")
                                .font(.headline)
                            Text("Настройки аккаунта и безопасности")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Профиль")
                }
                
                // App Settings Section
                Section {
                    SettingsRow(
                        icon: "bell.fill",
                        title: "Уведомления",
                        subtitle: "Настройка push-уведомлений",
                        color: .orange
                    ) {
                        // Open notifications settings
                    }
                    
                    SettingsRow(
                        icon: "moon.fill",
                        title: "Темная тема",
                        subtitle: "Автоматически",
                        color: .purple
                    ) {
                        // Open appearance settings
                    }
                    
                    SettingsRow(
                        icon: "globe",
                        title: "Язык",
                        subtitle: "Русский",
                        color: .blue
                    ) {
                        // Open language settings
                    }
                } header: {
                    Text("Настройки приложения")
                }
                
                // Security Section
                Section {
                    SettingsRow(
                        icon: "faceid",
                        title: "Face ID / Touch ID",
                        subtitle: "Быстрый вход в приложение",
                        color: .green
                    ) {
                        // Toggle biometric authentication
                    }
                    
                    SettingsRow(
                        icon: "key.fill",
                        title: "Изменить пароль",
                        subtitle: "Обновить пароль от ИИС",
                        color: .blue
                    ) {
                        // Open change password
                    }
                } header: {
                    Text("Безопасность")
                }
                
                // Support Section
                Section {
                    SettingsRow(
                        icon: "questionmark.circle.fill",
                        title: "Помощь",
                        subtitle: "Часто задаваемые вопросы",
                        color: .blue
                    ) {
                        // Open help
                    }
                    
                    SettingsRow(
                        icon: "envelope.fill",
                        title: "Связаться с поддержкой",
                        subtitle: "Сообщить о проблеме",
                        color: .green
                    ) {
                        openSupport()
                    }
                    
                    Button(action: { showingAbout = true }) {
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: "О приложении",
                            subtitle: "Версия и информация",
                            color: .purple
                        ) {
                            // Action handled by button
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                } header: {
                    Text("Поддержка")
                }
                
                // Logout Section
                Section {
                    Button(action: { showingLogoutAlert = true }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Text("Выйти")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                
                // App Info Footer
                Section {
                    VStack(spacing: 8) {
                        Text("БГУИР ИИС")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Курсовая работа по C++")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("iOS приложение с C++ бэкендом")
                            .font(.caption)
                            .foregroundColor(.tertiary)
                        
                        Text("Версия 1.0.0")
                            .font(.caption2)
                            .foregroundColor(.quaternary)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Выход из аккаунта", isPresented: $showingLogoutAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Выйти", role: .destructive) {
                logout()
            }
        } message: {
            Text("Вы уверены, что хотите выйти из аккаунта?")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    // MARK: - Methods
    
    private func logout() {
        BSUIRAPIBridge.shared().logout()
        // This would typically trigger a state change to show login screen
        // For now, we'll just reset the app state through the parent view
    }
    
    private func openSupport() {
        if let url = URL(string: "mailto:vlad.vasilevskiy.07@gmail.com?subject=BSUIR%20IIS%20App%20Support") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(color)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon
                    VStack(spacing: 16) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text("БГУИР ИИС")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Версия 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Описание")
                            .font(.headline)
                        
                        Text("Это iOS приложение для работы с Информационно-образовательной системой БГУИР, разработанное в рамках курсовой работы по C++.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("Особенности:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureItem(text: "C++ бэкенд для обработки данных")
                            FeatureItem(text: "SwiftUI интерфейс")
                            FeatureItem(text: "Objective-C++ мост")
                            FeatureItem(text: "Биометрическая аутентификация")
                            FeatureItem(text: "Соответствие Apple HIG")
                        }
                    }
                    
                    // Technical Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Техническая информация")
                            .font(.headline)
                        
                        TechInfoRow(title: "Платформа", value: "iOS 18+")
                        TechInfoRow(title: "Архитектура", value: "C++ Core + SwiftUI")
                        TechInfoRow(title: "Xcode", value: "16.4")
                        TechInfoRow(title: "Язык UI", value: "Swift")
                        TechInfoRow(title: "Язык бэкенда", value: "C++")
                    }
                    
                    // Developer Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Разработчик")
                            .font(.headline)
                        
                        HStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text("ВВ")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Василевский Владислав")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                
                                Text("Студент группы 420603, ФИТУ")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .navigationTitle("О приложении")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Feature Item

struct FeatureItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// MARK: - Tech Info Row

struct TechInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SettingsView()
}