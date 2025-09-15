import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @Binding var isLoading: Bool
    
    @StateObject private var credentialsManager = CredentialsManager()
    
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
                                        .textContentType(.username) // Enable autofill for username
                                }
                                
                                // Password Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Пароль")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    SecureField("Введите пароль", text: $password)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .textContentType(.password) // Enable autofill for password
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
                            if credentialsManager.biometricAuthAvailable && credentialsManager.hasStoredCredentials {
                                BiometricLoginButton(credentialsManager: credentialsManager) {
                                    Task {
                                        await authenticateWithBiometrics()
                                    }
                                }
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
            loadSavedCredentials()
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
        guard isFormValid else { 
            print("🚫 LoginView: Form validation failed")
            print("   - Student number empty: \(studentNumber.isEmpty)")
            print("   - Password empty: \(password.isEmpty)")
            return 
        }
        
        let trimmedStudentNumber = studentNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("🚀 LoginView: Starting login process")
        print("👤 Student Number: '\(trimmedStudentNumber)'")
        print("� Password length: \(password.count)")
        print("� Remember credentials: \(rememberCredentials)")
        
        isLoading = true
        
        BSUIRAPIBridge.shared().login(
            withStudentNumber: trimmedStudentNumber,
            password: password
        ) { (user: AnyObject?, error: Error?) in
            let workItem = DispatchWorkItem {
                // logStore.info("Получен ответ от сервера", category: "Auth")
                print("🔄 LoginView: Received login response")
                isLoading = false
                
                if let error = error {
                    // logStore.error("Ошибка аутентификации", category: "Auth", 
                    //              metadata: ["error": error.localizedDescription])
                    print("❌ LoginView: Login failed with error")
                    print("❌ Error description: \(error.localizedDescription)")
                    
                    // Cast to NSError to access domain and code
                    let nsError = error as NSError
                    // logStore.debug("Детали ошибки", category: "Auth", 
                    //              metadata: [
                    //                 "domain": nsError.domain,
                    //                 "code": String(nsError.code),
                    //                 "description": error.localizedDescription
                    //              ])
                    print("❌ Error domain: \(nsError.domain)")
                    print("❌ Error code: \(nsError.code)")
                    
                    if let failureReason = nsError.localizedFailureReason {
                        // logStore.debug("Причина ошибки", category: "Auth", 
                        //              metadata: ["reason": failureReason])
                        print("❌ Failure reason: \(failureReason)")
                    }
                    
                    // Create detailed error message for user
                    var detailedError = error.localizedDescription
                    
                    // Check if we have more specific error information
                    let userInfo = nsError.userInfo
                    print("🔍 UserInfo keys: \(userInfo.keys)")
                    print("🔍 Full UserInfo: \(userInfo)")
                    
                    // Try to get the actual server response details
                    if let failureReason = userInfo[NSLocalizedFailureReasonErrorKey] as? String {
                        print("📋 Server response details: \(failureReason)")
                        if failureReason != "No details available" && !failureReason.isEmpty {
                            detailedError = "Ошибка сервера: \(failureReason)"
                        }
                    }
                    
                    // Also check for other error details
                    if let description = userInfo[NSLocalizedDescriptionKey] as? String {
                        print("📝 Error description: \(description)")
                    }
                    
                    // Try to get more detailed error info
                    for (key, value) in userInfo {
                        print("🔑 UserInfo[\(key)]: \(value)")
                    }                    // Only use generic messages if no specific server info available
                    if detailedError == error.localizedDescription {
                        print("🚨 Using fallback error messages for code: \(nsError.code)")
                        if nsError.code == 401 {
                            detailedError = "Ошибка 401: Неверный номер студенческого билета или пароль"
                        } else if nsError.code == 400 {
                            detailedError = "Ошибка 400: Неверный формат данных. Проверьте правильность ввода"
                        } else if nsError.code >= 500 {
                            detailedError = "Ошибка \(nsError.code): Сервер временно недоступен. Попробуйте позже"
                        } else if nsError.code == -1009 {
                            detailedError = "Нет подключения к интернету"
                        } else {
                            detailedError = "Код ошибки: \(nsError.code) - \(error.localizedDescription)"
                        }
                    }
                    
                    print("🚨 Final error message to show: \(detailedError)")
                    errorMessage = detailedError
                    showingError = true
                } else if let _ = user {
                    print("🎉 LoginView: Login successful!")
                    print("👤 User data received")
                    
                    // Save credentials if remember me is enabled
                    if rememberCredentials {
                        print("💾 LoginView: Saving credentials to secure storage")
                        Task {
                            do {
                                try await MainActor.run {
                                    try credentialsManager.saveCredentials(
                                        studentNumber: trimmedStudentNumber,
                                        password: password,
                                        rememberCredentials: rememberCredentials
                                    )
                                }
                            } catch {
                                print("❌ Failed to save credentials: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    isAuthenticated = true
                } else {
                    print("❌ LoginView: Unexpected state - no user and no error")
                    errorMessage = "Неизвестная ошибка. Попробуйте еще раз"
                    showingError = true
                }
            }
            DispatchQueue.main.async(execute: workItem)
        }
    }
    
    private func fillTestCredentials() {
        studentNumber = "YOUR_STUDENT_NUMBER"
        password = "YOUR_PASSWORD"
    }
    
    private func authenticateWithBiometrics() async {
        let success = await credentialsManager.authenticateWithBiometrics()
        
        if success {
            if let credentials = credentialsManager.loadCredentials() {
                studentNumber = credentials.studentNumber
                password = credentials.password
                rememberCredentials = true
                
                // Auto-login after biometric authentication
                performLogin()
            }
        }
    }
    
    private func loadSavedCredentials() {
        // Load saved credentials on view appear
        if let credentials = credentialsManager.loadCredentials() {
            studentNumber = credentials.studentNumber
            password = credentials.password
            rememberCredentials = true
        }
    }
}

// MARK: - Biometric Login Button

struct BiometricLoginButton: View {
    let credentialsManager: CredentialsManager
    let action: () -> Void
    
    var body: some View {
        if credentialsManager.biometricAuthAvailable {
            Button(action: action) {
                HStack {
                    Image(systemName: biometricIcon)
                    Text("Войти с \(biometricText)")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
    }
    
    private var biometricIcon: String {
        switch credentialsManager.biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        default:
            return "person.badge.key"
        }
    }
    
    private var biometricText: String {
        switch credentialsManager.biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        default:
            return "биометрией"
        }
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false), isLoading: .constant(false))
}