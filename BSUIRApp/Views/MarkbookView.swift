import SwiftUI

struct MarkbookView: View {
    @State private var markbook: BSUIRMarkbook?
    @State private var isLoading = false
    @State private var selectedSemester: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    loadingView
                } else if let markbook = markbook {
                    markbookContent(markbook)
                } else {
                    errorView
                }
            }
            .navigationTitle("Зачетная книжка")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadMarkbook()
            }
            .refreshable {
                loadMarkbook()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Загрузка зачетной книжки...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Не удалось загрузить зачетную книжку")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("Проверьте подключение к интернету")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Попробовать снова") {
                loadMarkbook()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Markbook Content
    
    private func markbookContent(_ markbook: BSUIRMarkbook) -> some View {
        VStack(spacing: 0) {
            // Overall GPA Header
            overallGPAHeader(markbook)
            
            // Semester Picker
            if !markbook.semesters.isEmpty {
                semesterPicker(markbook.semesters)
            }
            
            // Subjects List
            if !markbook.semesters.isEmpty && selectedSemester < markbook.semesters.count {
                subjectsList(markbook.semesters[selectedSemester])
            }
        }
    }
    
    // MARK: - Overall GPA Header
    
    private func overallGPAHeader(_ markbook: BSUIRMarkbook) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Средний балл")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.2f", markbook.overallGPA))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(gpaColor(markbook.overallGPA))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("№ \(markbook.studentNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    GPAIndicator(gpa: markbook.overallGPA)
                }
            }
        }
        .padding(20)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Semester Picker
    
    private func semesterPicker(_ semesters: [BSUIRSemester]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<semesters.count, id: \.self) { index in
                    let semester = semesters[index]
                    
                    Button(action: {
                        selectedSemester = index
                    }) {
                        VStack(spacing: 8) {
                            Text("\(semester.number) семестр")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            if semester.gpa > 0 {
                                Text(String(format: "%.2f", semester.gpa))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("В процессе")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(selectedSemester == index ? Color.blue : Color(.systemGray6))
                        .foregroundColor(selectedSemester == index ? .white : .primary)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Subjects List
    
    private func subjectsList(_ semester: BSUIRSemester) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<semester.subjects.count, id: \.self) { index in
                    let subject = semester.subjects[index]
                    SubjectCard(subject: subject)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Helper Methods
    
    private func gpaColor(_ gpa: Double) -> Color {
        switch gpa {
        case 9.0...:
            return .green
        case 7.0..<9.0:
            return .blue
        case 5.0..<7.0:
            return .orange
        default:
            return .red
        }
    }
    
    private func loadMarkbook() {
        isLoading = true
        
        BSUIRAPIBridge.shared().getMarkbook { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let result = result {
                    markbook = result
                    // Select the latest semester by default
                    if !result.semesters.isEmpty {
                        selectedSemester = result.semesters.count - 1
                    }
                }
            }
        }
    }
}

// MARK: - GPA Indicator

struct GPAIndicator: View {
    let gpa: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 8)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: CGFloat(gpa / 10.0))
                .stroke(gpaColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: gpa)
            
            Text(String(format: "%.1f", gpa))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(gpaColor)
        }
    }
    
    private var gpaColor: Color {
        switch gpa {
        case 9.0...:
            return .green
        case 7.0..<9.0:
            return .blue
        case 5.0..<7.0:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - Subject Card

struct SubjectCard: View {
    let subject: BSUIRSubject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Subject Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subject.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(subject.controlForm)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                // Grade Display
                if let grade = subject.grade {
                    GradeView(grade: grade.intValue)
                } else {
                    Text("—")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            }
            
            // Subject Details
            HStack {
                DetailBadge(icon: "clock", text: "\(Int(subject.hours)) ч", color: .blue)
                DetailBadge(icon: "star", text: "\(subject.credits) кр", color: .green)
                
                if subject.isOnline {
                    DetailBadge(icon: "wifi", text: "Онлайн", color: .purple)
                }
                
                if subject.retakes > 0 {
                    DetailBadge(icon: "arrow.counterclockwise", text: "\(subject.retakes)", color: .orange)
                }
                
                Spacer()
            }
            
            // Average Grade and Retake Chance
            if let avgGrade = subject.averageGrade {
                HStack {
                    Text("Средний балл группы: \(String(format: "%.2f", avgGrade.doubleValue))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if subject.retakeChance > 0 {
                        Text("Вероятность пересдачи: \(Int(subject.retakeChance * 100))%")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Grade View

struct GradeView: View {
    let grade: Int
    
    var body: some View {
        Text("\(grade)")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 40, height: 40)
            .background(gradeColor)
            .cornerRadius(20)
    }
    
    private var gradeColor: Color {
        switch grade {
        case 9...10:
            return .green
        case 7...8:
            return .blue
        case 5...6:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - Detail Badge

struct DetailBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

#Preview {
    MarkbookView()
}