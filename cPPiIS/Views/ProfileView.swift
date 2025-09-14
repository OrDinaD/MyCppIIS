import SwiftUI

struct ProfileView: View {
    @Binding var personalInfo: BSUIRPersonalInfo?
    @Binding var isLoading: Bool
    
    @State private var showingFullProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                if isLoading {
                    loadingView
                } else if let info = personalInfo {
                    profileContent(info)
                } else {
                    errorView
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                refreshProfile()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Загрузка профиля...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Error View
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Не удалось загрузить профиль")
                .font(.headline)
            
            Text("Проверьте подключение к интернету и попробуйте снова")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Попробовать снова") {
                refreshProfile()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Profile Content
    
    private func profileContent(_ info: BSUIRPersonalInfo) -> some View {
        LazyVStack(spacing: 24) {
            // Header Card
            headerCard(info)
            
            // Academic Info Card
            academicInfoCard(info)
            
            // Personal Info Card
            personalInfoCard(info)
            
            // Contact Info Card
            contactInfoCard(info)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Header Card
    
    private func headerCard(_ info: BSUIRPersonalInfo) -> some View {
        VStack(spacing: 16) {
            // Profile Picture Placeholder
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.7), .purple.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 100, height: 100)
                .overlay(
                    Text(getInitials(from: info))
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 8) {
                Text("\(info.lastName) \(info.firstName)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if !info.middleName.isEmpty {
                    Text(info.middleName)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                Text("Студент БГУИР")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Academic Info Card
    
    private func academicInfoCard(_ info: BSUIRPersonalInfo) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(.blue)
                Text("Академическая информация")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                infoRow("Факультет", value: info.faculty, icon: "building.2")
                infoRow("Специальность", value: info.speciality, icon: "book")
                infoRow("Группа", value: info.group, icon: "person.3")
                infoRow("Курс", value: "\(info.course)", icon: "number")
                infoRow("№ студ. билета", value: info.studentNumber, icon: "creditcard")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Personal Info Card
    
    private func personalInfoCard(_ info: BSUIRPersonalInfo) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.text.rectangle")
                    .foregroundColor(.green)
                Text("Личная информация")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                if !info.birthDate.isEmpty {
                    infoRow("Дата рождения", value: formatDate(info.birthDate), icon: "calendar")
                }
                
                if !info.firstNameBel.isEmpty || !info.lastNameBel.isEmpty {
                    let fullNameBel = "\(info.lastNameBel) \(info.firstNameBel) \(info.middleNameBel)".trimmingCharacters(in: .whitespaces)
                    if !fullNameBel.isEmpty {
                        infoRow("ФИО (бел.)", value: fullNameBel, icon: "person")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Contact Info Card
    
    private func contactInfoCard(_ info: BSUIRPersonalInfo) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.orange)
                Text("Контактная информация")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                if !info.email.isEmpty {
                    contactRow("Email", value: info.email, icon: "envelope", action: {
                        openEmail(info.email)
                    })
                }
                
                if !info.phone.isEmpty {
                    contactRow("Телефон", value: info.phone, icon: "phone", action: {
                        callPhone(info.phone)
                    })
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Helper Views
    
    private func infoRow(_ title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
    }
    
    private func contactRow(_ title: String, value: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getInitials(from info: BSUIRPersonalInfo) -> String {
        let firstInitial = info.firstName.prefix(1).uppercased()
        let lastInitial = info.lastName.prefix(1).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "dd.MM.yyyy"
            return formatter.string(from: date)
        }
        
        return dateString
    }
    
    private func refreshProfile() {
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
    
    private func openEmail(_ email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func callPhone(_ phone: String) {
        let cleanPhone = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        if let url = URL(string: "tel:\(cleanPhone)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    let sampleInfo = BSUIRPersonalInfo()
    sampleInfo.studentNumber = "42850012"
    sampleInfo.firstName = "Владислав"
    sampleInfo.lastName = "Василевский"
    sampleInfo.middleName = "Валерьевич"
    sampleInfo.course = 2
    sampleInfo.faculty = "ФИТУ"
    sampleInfo.speciality = "СУИ (АСОИ)"
    sampleInfo.group = "420603"
    sampleInfo.email = "vlad.vasilevskiy.07@gmail.com"
    sampleInfo.phone = "+375299605390"
    sampleInfo.birthDate = "2007-06-14"
    
    return ProfileView(personalInfo: .constant(sampleInfo), isLoading: .constant(false))
}