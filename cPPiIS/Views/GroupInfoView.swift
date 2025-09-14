import SwiftUI

struct GroupInfoView: View {
    @State private var groupInfo: BSUIRGroupInfo?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    loadingView
                } else if let groupInfo = groupInfo {
                    groupContent(groupInfo)
                } else {
                    errorView
                }
            }
            .navigationTitle("Группа")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadGroupInfo()
            }
            .refreshable {
                loadGroupInfo()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Загрузка информации о группе...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Не удалось загрузить информацию о группе")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("Проверьте подключение к интернету")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Попробовать снова") {
                loadGroupInfo()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Group Content
    
    private func groupContent(_ groupInfo: BSUIRGroupInfo) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Group Header
                groupHeader(groupInfo)
                
                // Curator Info
                curatorCard(groupInfo.curator)
                
                // Students List
                studentsSection(groupInfo.students)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Group Header
    
    private func groupHeader(_ groupInfo: BSUIRGroupInfo) -> some View {
        VStack(spacing: 16) {
            // Group Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.7), .purple.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Группа \(groupInfo.number)")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack(spacing: 16) {
                    InfoChip(icon: "building.2", text: groupInfo.faculty, color: .blue)
                    InfoChip(icon: "number", text: "\(groupInfo.course) курс", color: .green)
                }
            }
            
            HStack(spacing: 12) {
                Image(systemName: "person.2")
                    .foregroundColor(.secondary)
                Text("Студентов в группе: \(groupInfo.students.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Curator Card
    
    private func curatorCard(_ curator: BSUIRCurator) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.badge.key")
                    .foregroundColor(.orange)
                Text("Куратор группы")
                    .font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(getInitials(from: curator.fullName))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(curator.fullName)
                            .font(.body)
                            .fontWeight(.semibold)
                        
                        Text("Куратор")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                VStack(spacing: 8) {
                    if !curator.phone.isEmpty {
                        ContactRow(
                            icon: "phone.fill",
                            title: "Телефон",
                            value: curator.phone,
                            color: .green
                        ) {
                            callPhone(curator.phone)
                        }
                    }
                    
                    if !curator.email.isEmpty {
                        ContactRow(
                            icon: "envelope.fill",
                            title: "Email",
                            value: curator.email,
                            color: .blue
                        ) {
                            openEmail(curator.email)
                        }
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
    
    // MARK: - Students Section
    
    private func studentsSection(_ students: [BSUIRGroupStudent]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.3.sequence")
                    .foregroundColor(.purple)
                Text("Список студентов")
                    .font(.headline)
                Spacer()
                Text("\(students.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(0..<students.count, id: \.self) { index in
                    let student = students[index]
                    StudentRow(student: student)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Helper Methods
    
    private func getInitials(from fullName: String) -> String {
        let components = fullName.split(separator: " ")
        if components.count >= 2 {
            let firstInitial = String(components[1].prefix(1)).uppercased()
            let lastInitial = String(components[0].prefix(1)).uppercased()
            return "\(firstInitial)\(lastInitial)"
        }
        return String(fullName.prefix(2)).uppercased()
    }
    
    private func loadGroupInfo() {
        isLoading = true
        
        BSUIRAPIBridge.shared().getGroupInfo { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let result = result {
                    groupInfo = result
                }
            }
        }
    }
    
    private func callPhone(_ phone: String) {
        let cleanPhone = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        if let url = URL(string: "tel:\(cleanPhone)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openEmail(_ email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Info Chip

struct InfoChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Contact Row

struct ContactRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
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
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Student Row

struct StudentRow: View {
    let student: BSUIRGroupStudent
    
    var body: some View {
        HStack(spacing: 12) {
            // Student Number Badge
            Text("\(student.number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(numberColor)
                .cornerRadius(12)
            
            // Student Name
            Text(student.fullName)
                .font(.body)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
    
    private var numberColor: Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red]
        return colors[student.number % colors.count]
    }
}

#Preview {
    GroupInfoView()
}