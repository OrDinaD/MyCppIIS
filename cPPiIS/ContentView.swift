//
//  ContentView.swift
//  Простое SwiftUI приложение для тестирования BSUIR IIS API
//

import SwiftUI

struct ContentView: View {
    @State private var studentNumber = "42850012"
    @State private var password = "Bsuirinyouv.12_"
    @State private var loginResult = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("BSUIR IIS API Тест")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("Номер студенческого", text: $studentNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    
                    SecureField("Пароль", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: testLogin) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Войти")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isLoading)
                    
                    // Дополнительные кнопки для тестирования разных форматов
                    HStack(spacing: 10) {
                        Button("Формат 1") { testLoginFormat1() }
                            .buttonStyle(.bordered)
                            .disabled(isLoading)
                        
                        Button("Формат 2") { testLoginFormat2() }
                            .buttonStyle(.bordered)
                            .disabled(isLoading)
                        
                        Button("Формат 3") { testLoginFormat3() }
                            .buttonStyle(.bordered)
                            .disabled(isLoading)
                    }
                    .font(.caption)
                }
                .padding(.horizontal)
                
                ScrollView {
                    Text(loginResult)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("BSUIR API")
        }
    }
    
    // Тестируем оригинальный формат с "login"
    private func testLoginFormat1() {
        performLogin(loginData: [
            "login": studentNumber,
            "password": password,
            "rememberMe": true
        ], format: "Формат 1 (login + rememberMe)")
    }
    
    // Тестируем формат с "username"
    private func testLoginFormat2() {
        performLogin(loginData: [
            "username": studentNumber,
            "password": password
        ], format: "Формат 2 (username)")
    }
    
    // Тестируем формат с "studentNumber"
    private func testLoginFormat3() {
        performLogin(loginData: [
            "studentNumber": studentNumber,
            "password": password
        ], format: "Формат 3 (studentNumber)")
    }
    
    private func performLogin(loginData: [String: Any], format: String) {
        isLoading = true
        loginResult = "Выполняется вход (\(format))...\n"
        
        // Создаем URL и запрос
        let loginURL = URL(string: "https://iis.bsuir.by/api/v1/auth/login")!
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData)
            
            // Логируем отправляемые данные
            if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                loginResult += "Отправляем: \(bodyString)\n"
            }
            
            // Выполняем запрос
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    if let error = error {
                        loginResult += "Ошибка: \(error.localizedDescription)\n"
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        loginResult += "HTTP Status: \(httpResponse.statusCode)\n"
                        
                        // Показываем заголовки ответа
                        if !httpResponse.allHeaderFields.isEmpty {
                            loginResult += "Заголовки ответа:\n"
                            for (key, value) in httpResponse.allHeaderFields {
                                loginResult += "  \(key): \(value)\n"
                            }
                        }
                    }
                    
                    if let data = data,
                       let responseString = String(data: data, encoding: .utf8) {
                        loginResult += "Ответ: \(responseString)\n"
                        
                        // Попытка парсинга JSON
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                loginResult += "Parsed JSON:\n"
                                for (key, value) in json {
                                    loginResult += "  \(key): \(value)\n"
                                }
                            }
                        } catch {
                            loginResult += "Ошибка парсинга JSON: \(error)\n"
                        }
                    }
                }
            }.resume()
            
        } catch {
            isLoading = false
            loginResult += "Ошибка создания запроса: \(error)\n"
        }
    }
    
    private func testLogin() {
        testLoginFormat1() // По умолчанию используем формат 1
    }
}

#Preview {
    ContentView()
}
