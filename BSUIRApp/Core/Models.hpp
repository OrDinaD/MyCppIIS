//
//  Models.hpp
//  BSUIRApp Core C++ Models
//
//  Data models for BSUIR IIS API responses
//

#ifndef Models_hpp
#define Models_hpp

#include <string>
#include <vector>
#include <optional>

namespace BSUIR {

// User authentication response
struct LoginResponse {
    std::string accessToken;
    std::string refreshToken;
    std::string tokenType;
    int expiresIn;
    
    // User basic info
    int userId;
    std::string studentNumber;
    std::string firstName;
    std::string lastName;
    std::string middleName;
};

// Personal information model
struct PersonalInfo {
    int id;
    std::string studentNumber;
    std::string firstName;
    std::string lastName;
    std::string middleName;
    std::string firstNameBel;
    std::string lastNameBel;
    std::string middleNameBel;
    std::string birthDate;
    int course;
    std::string faculty;
    std::string speciality;
    std::string group;
    std::string email;
    std::string phone;
};

// Subject in markbook
struct Subject {
    std::string name;
    double hours;
    int credits;
    std::string controlForm;
    std::optional<int> grade;
    int retakes;
    std::optional<double> averageGrade;
    double retakeChance;
    bool isOnline;
};

// Semester data
struct Semester {
    int number;
    double gpa;
    std::vector<Subject> subjects;
};

// Markbook data
struct Markbook {
    std::string studentNumber;
    double overallGPA;
    std::vector<Semester> semesters;
};

// Group curator info
struct Curator {
    std::string fullName;
    std::string phone;
    std::string email;
    std::string profileUrl;
};

// Student in group
struct GroupStudent {
    int number;
    std::string fullName;
};

// Group information
struct GroupInfo {
    std::string number;
    std::string faculty;
    int course;
    Curator curator;
    std::vector<GroupStudent> students;
};

// API Error
struct ApiError {
    int code;
    std::string message;
    std::string details;
};

// Result wrapper for API responses
template<typename T>
struct ApiResult {
    bool success;
    std::optional<T> data;
    std::optional<ApiError> error;
    
    ApiResult(T&& data) : success(true), data(std::move(data)) {}
    ApiResult(const ApiError& error) : success(false), error(error) {}
};

} // namespace BSUIR

#endif /* Models_hpp */