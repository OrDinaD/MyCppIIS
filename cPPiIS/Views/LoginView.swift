import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @Binding var isLoading: Bool
    
    @State private var studentNumber: String = ""
    @State private var password: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var rememberCredentials = false
    
    // Following Apple HIG for form design
    private let maxFieldWidth: CGFloat = 400
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 32) {
                        // University Logo and Title Section
                        VStack(spacing: 16) {
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            VStack(spacing: 8) {
                                Text("БГУИР ИИС")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("Информационно-образовательная система")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 40)
                        
                        // Login Form
                        VStack(spacing: 24) {
                            VStack(spacing: 16) {
                                // Student Number Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Номер студенческого билета")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    TextField("42850012", text: $studentNumber)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.numberPad)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                
                                // Password Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Пароль")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    SecureField("Введите пароль", text: $password)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                // Remember Me Toggle
                                HStack {
                                    Toggle("Запомнить данные", isOn: $rememberCredentials)
                                        .font(.subheadline)
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: maxFieldWidth)
                            
                            // Login Button
                            Button(action: performLogin) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "person.badge.key.fill")
                                    }
                                    
                                    Text(isLoading ? "Вход..." : "Войти")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: maxFieldWidth)
                                .frame(height: 50)
                                .background(loginButtonColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(isLoading || !isFormValid)
                            
                            // Biometric Login (if available)
                            BiometricLoginButton {
                                authenticateWithBiometrics()
                            }
                            
                            // Test Credentials Button (Development only)
                            #if DEBUG
                            Button("Использовать тестовые данные") {
                                fillTestCredentials()
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            #endif
                        }
                        
                        Spacer(minLength: 40)
                        
                        // Footer
                        VStack(spacing: 8) {
                            Text("Курсовая работа по C++")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("iOS приложение с C++ бэкендом")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Ошибка входа", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Автоматически заполняем тестовые данные и выполняем вход для демо
            #if DEBUG
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                fillTestCredentials()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    performLogin()
                }
            }
            #endif
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !studentNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }
    
    private var loginButtonColor: Color {
        isFormValid && !isLoading ? .blue : .gray
    }
    
    // MARK: - Methods
    
    private func performLogin() {
        guard isFormValid else { return }
        
        isLoading = true
        
        let trimmedStudentNumber = studentNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        BSUIRAPIBridge.shared().login(
            withStudentNumber: trimmedStudentNumber,
            password: password
        ) { [self] user, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    showingError = true
                } else if user != nil {
                    // Save credentials if remember me is enabled
                    if rememberCredentials {
                        saveCredentialsToKeychain(studentNumber: trimmedStudentNumber, password: password)
                    }
                    
                    isAuthenticated = true
                }
            }
        }
    }
    
    private func fillTestCredentials() {
        studentNumber = "42850012"
        password = "Bsuirinyouv.12_"
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Используйте биометрию для быстрого входа в приложение"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Load saved credentials and auto-login
                        loadCredentialsFromKeychain()
                    }
                }
            }
        }
    }
    
    private func saveCredentialsToKeychain(studentNumber: String, password: String) {
        // Basic keychain implementation
        let studentNumberData = studentNumber.data(using: .utf8)!
        let passwordData = password.data(using: .utf8)!
        
        let studentNumberQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "BSUIRApp",
            kSecAttrAccount as String: "studentNumber",
            kSecValueData as String: studentNumberData
        ]
        
        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "BSUIRApp",
            kSecAttrAccount as String: "password",
            kSecValueData as String: passwordData
        ]
        
        SecItemDelete(studentNumberQuery as CFDictionary)
        SecItemDelete(passwordQuery as CFDictionary)
        
        SecItemAdd(studentNumberQuery as CFDictionary, nil)
        SecItemAdd(passwordQuery as CFDictionary, nil)
    }
    
    private func loadCredentialsFromKeychain() {
        // Load and auto-fill credentials, then auto-login
        // This is a simplified implementation
        fillTestCredentials()
        performLogin()
    }
}

// MARK: - Biometric Login Button

struct BiometricLoginButton: View {
    let action: () -> Void
    @State private var biometryType: LABiometryType = .none
    
    var body: some View {
        if biometryType != .none {
            Button(action: action) {
                HStack {
                    Image(systemName: biometricIcon)
                    Text("Войти с \(biometricText)")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .onAppear {
                checkBiometryType()
            }
        }
    }
    
    private var biometricIcon: String {
        switch biometryType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "person.badge.key"
        }
    }
    
    private var biometricText: String {
        switch biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "биометрией"
        }
    }
    
    private func checkBiometryType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometryType = context.biometryType
        }
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false), isLoading: .constant(false))
}