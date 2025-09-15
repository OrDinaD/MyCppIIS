//
//  CredentialsManager.swift
//  cPPiIS
//
//  Modern Swift credentials management with iOS 18.6 autofill support
//

import Foundation
import Security
import LocalAuthentication

@MainActor
class CredentialsManager: ObservableObject {
    
    // MARK: - Properties
    
    private let biometricContext = LAContext()
    
    @Published var hasStoredCredentials: Bool = false
    @Published var biometricAuthAvailable: Bool = false
    @Published var biometricType: LABiometryType = .none
    
    // MARK: - Constants
    
    private enum Keys {
        static let studentNumber = "bsuir_student_number"
        static let password = "bsuir_password"
        static let rememberCredentials = "bsuir_remember_credentials"
        static let biometricEnabled = "bsuir_biometric_enabled"
    }
    
    private let service = "by.bsuir.iis"
    
    // MARK: - Initialization
    
    init() {
        checkStoredCredentials()
        setupBiometricCapabilities()
    }
    
    // MARK: - Credential Storage
    
    func saveCredentials(studentNumber: String, password: String, rememberCredentials: Bool = true) throws {
        guard !studentNumber.isEmpty && !password.isEmpty else {
            throw CredentialsError.invalidCredentials
        }
        
        do {
            // Save student number in UserDefaults (not sensitive)
            UserDefaults.standard.set(studentNumber, forKey: Keys.studentNumber)
            
            // Save password securely in Keychain
            try saveToKeychain(key: Keys.password, value: password)
            
            // Save preference
            UserDefaults.standard.set(rememberCredentials, forKey: Keys.rememberCredentials)
            
            hasStoredCredentials = true
            
            NSLog("✅ CredentialsManager: Credentials saved securely for student: %@", studentNumber)
            
        } catch {
            NSLog("❌ CredentialsManager: Failed to save credentials - %@", error.localizedDescription)
            throw CredentialsError.keychainError(error)
        }
    }
    
    func loadCredentials() -> (studentNumber: String, password: String)? {
        guard shouldRememberCredentials else { return nil }
        
        do {
            guard let studentNumber = UserDefaults.standard.string(forKey: Keys.studentNumber),
                  let password = try loadFromKeychain(key: Keys.password) else {
                return nil
            }
            
            NSLog("✅ CredentialsManager: Credentials loaded for student: %@", studentNumber)
            return (studentNumber: studentNumber, password: password)
            
        } catch {
            NSLog("❌ CredentialsManager: Failed to load credentials - %@", error.localizedDescription)
            return nil
        }
    }
    
    func clearCredentials() {
        do {
            UserDefaults.standard.removeObject(forKey: Keys.studentNumber)
            try deleteFromKeychain(key: Keys.password)
            UserDefaults.standard.removeObject(forKey: Keys.rememberCredentials)
            UserDefaults.standard.removeObject(forKey: Keys.biometricEnabled)
            
            hasStoredCredentials = false
            
            NSLog("✅ CredentialsManager: Credentials cleared successfully")
            
        } catch {
            NSLog("❌ CredentialsManager: Failed to clear credentials - %@", error.localizedDescription)
        }
    }
    
    // MARK: - Biometric Authentication
    
    func authenticateWithBiometrics() async -> Bool {
        guard biometricAuthAvailable else { return false }
        
        let reason = "Войти в БГУИР ИИС с помощью биометрии"
        
        do {
            let success = try await biometricContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            if success {
                NSLog("✅ CredentialsManager: Biometric authentication successful")
            }
            
            return success
            
        } catch {
            NSLog("❌ CredentialsManager: Biometric authentication failed - %@", error.localizedDescription)
            return false
        }
    }
    
    func enableBiometricAuth(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Keys.biometricEnabled)
    }
    
    var isBiometricEnabled: Bool {
        return UserDefaults.standard.bool(forKey: Keys.biometricEnabled)
    }
    
    // MARK: - Keychain Operations
    
    private func saveToKeychain(key: String, value: String) throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw CredentialsError.keychainError(NSError(domain: "KeychainError", code: Int(status), userInfo: nil))
        }
    }
    
    private func loadFromKeychain(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw CredentialsError.keychainError(NSError(domain: "KeychainError", code: Int(status), userInfo: nil))
        }
        
        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    private func deleteFromKeychain(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        // Don't throw error if item doesn't exist
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw CredentialsError.keychainError(NSError(domain: "KeychainError", code: Int(status), userInfo: nil))
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkStoredCredentials() {
        let hasStudentNumber = UserDefaults.standard.string(forKey: Keys.studentNumber) != nil
        let hasPassword = (try? loadFromKeychain(key: Keys.password)) != nil
        hasStoredCredentials = hasStudentNumber && hasPassword
    }
    
    private func setupBiometricCapabilities() {
        var error: NSError?
        biometricAuthAvailable = biometricContext.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics, 
            error: &error
        )
        
        if biometricAuthAvailable {
            biometricType = biometricContext.biometryType
            NSLog("✅ CredentialsManager: Biometric auth available - %@", biometricTypeString)
        } else {
            NSLog("❌ CredentialsManager: Biometric auth not available - %@", error?.localizedDescription ?? "Unknown")
        }
    }
    
    private var shouldRememberCredentials: Bool {
        return UserDefaults.standard.bool(forKey: Keys.rememberCredentials)
    }
    
    private var biometricTypeString: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "None"
        @unknown default:
            return "Unknown"
        }
    }
}

// MARK: - Errors

enum CredentialsError: LocalizedError {
    case invalidCredentials
    case keychainError(Error)
    case biometricNotAvailable
    case biometricFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Некорректные данные для входа"
        case .keychainError(let error):
            return "Ошибка безопасного хранения: \(error.localizedDescription)"
        case .biometricNotAvailable:
            return "Биометрическая аутентификация недоступна"
        case .biometricFailed:
            return "Биометрическая аутентификация не удалась"
        }
    }
}