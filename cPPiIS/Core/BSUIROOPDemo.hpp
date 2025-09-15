//
//  BSUIROOPDemo.hpp
//  Демонстрация ООП принципов для курсовой работы
//
//  @file BSUIROOPDemo.hpp
//  @brief Comprehensive demonstration of Object-Oriented Programming principles
//  @details This file contains complete examples of all 4 OOP principles:
//           Abstraction, Inheritance, Polymorphism, and Encapsulation
//  @author Course Work on OOP in C++
//  @date 2024
//

#ifndef BSUIROOPDemo_hpp
#define BSUIROOPDemo_hpp

#include <string>
#include <vector>
#include <memory>
#include <functional>
#include <iostream>
#include <mutex>

/**
 * @namespace BSUIR
 * @brief Main namespace for BSUIR IIS application demonstrating OOP principles
 */
namespace BSUIR {

// ========================================
// 1. АБСТРАКЦИЯ - Абстрактные базовые классы
// ========================================

/**
 * @class AbstractUser
 * @brief Абстрактный базовый класс для всех пользователей системы
 * @details Демонстрирует принцип абстракции и полиморфизма.
 *          Определяет общий интерфейс для всех типов пользователей,
 *          скрывая детали реализации в производных классах.
 * 
 * Применяемые принципы ООП:
 * - Абстракция: чисто виртуальные методы определяют интерфейс
 * - Полиморфизм: виртуальные методы для runtime polymorphism
 * - Инкапсуляция: защищенные члены доступны только наследникам
 */
class AbstractUser {
protected:
    std::string id;
    std::string name;
    std::string email;
    
public:
    AbstractUser(const std::string& id, const std::string& name, const std::string& email)
        : id(id), name(name), email(email) {}
    
    virtual ~AbstractUser() = default;
    
    // Чисто виртуальные методы - обязательны для реализации в наследниках
    virtual std::string getUserType() const = 0;
    virtual std::string getDisplayInfo() const = 0;
    virtual bool hasPermission(const std::string& permission) const = 0;
    
    // Виртуальные методы с реализацией по умолчанию
    virtual std::string getId() const { return id; }
    virtual std::string getName() const { return name; }
    virtual std::string getEmail() const { return email; }
    
    // Невиртуальный метод
    std::string getBasicInfo() const {
        return "ID: " + id + ", Name: " + name;
    }
};

/**
 * @class AbstractApiService
 * @brief Абстрактный класс для API сервисов
 * @details Демонстрирует Template Method pattern - один из классических
 *          паттернов проектирования. Определяет общий алгоритм выполнения
 *          запросов, позволяя наследникам настраивать отдельные шаги.
 * 
 * Применяемые паттерны:
 * - Template Method: makeRequest() определяет алгоритм
 * - Strategy: различные стратегии валидации и логирования
 */
class AbstractApiService {
protected:
    std::string baseUrl;
    std::string authToken;
    
    // Template method - определяет алгоритм, конкретные шаги в наследниках
    virtual bool validateRequest() const = 0;
    virtual std::string buildEndpoint() const = 0;
    virtual void logRequest() const = 0;
    
public:
    AbstractApiService(const std::string& baseUrl) : baseUrl(baseUrl) {}
    virtual ~AbstractApiService() = default;
    
    // Template Method - общий алгоритм для всех API запросов
    virtual bool makeRequest() final {
        if (!validateRequest()) {
            std::cout << "Request validation failed" << std::endl;
            return false;
        }
        
        logRequest();
        
        std::string endpoint = buildEndpoint();
        std::cout << "Making request to: " << endpoint << std::endl;
        
        return executeRequest(endpoint);
    }
    
    virtual void setAuthToken(const std::string& token) { authToken = token; }
    
protected:
    virtual bool executeRequest(const std::string& endpoint) = 0;
};

// ========================================
// 2. НАСЛЕДОВАНИЕ - Конкретные классы
// ========================================

/**
 * Класс студента - наследует от AbstractUser
 * Демонстрирует наследование и расширение функциональности
 */
class Student : public AbstractUser {
private:
    std::string studentNumber;
    std::string group;
    int course;
    std::vector<std::string> subjects;
    
public:
    Student(const std::string& id, const std::string& name, const std::string& email,
            const std::string& studentNumber, const std::string& group, int course)
        : AbstractUser(id, name, email), studentNumber(studentNumber), group(group), course(course) {}
    
    // Реализация чисто виртуальных методов
    std::string getUserType() const override {
        return "Student";
    }
    
    std::string getDisplayInfo() const override {
        return getName() + " (" + studentNumber + ") - " + group + ", " + std::to_string(course) + " курс";
    }
    
    bool hasPermission(const std::string& permission) const override {
        // Студенты имеют ограниченные права
        return permission == "view_grades" || permission == "view_schedule" || permission == "view_profile";
    }
    
    // Специфичные для студента методы
    std::string getStudentNumber() const { return studentNumber; }
    std::string getGroup() const { return group; }
    int getCourse() const { return course; }
    
    void addSubject(const std::string& subject) {
        subjects.push_back(subject);
    }
    
    const std::vector<std::string>& getSubjects() const { return subjects; }
};

/**
 * Класс преподавателя - наследует от AbstractUser
 */
class Teacher : public AbstractUser {
private:
    std::string department;
    std::string position;
    std::vector<std::string> teachingSubjects;
    
public:
    Teacher(const std::string& id, const std::string& name, const std::string& email,
            const std::string& department, const std::string& position)
        : AbstractUser(id, name, email), department(department), position(position) {}
    
    std::string getUserType() const override {
        return "Teacher";
    }
    
    std::string getDisplayInfo() const override {
        return getName() + " - " + position + " (" + department + ")";
    }
    
    bool hasPermission(const std::string& permission) const override {
        // Преподаватели имеют расширенные права
        return permission == "view_grades" || permission == "edit_grades" || 
               permission == "view_schedule" || permission == "edit_schedule" ||
               permission == "view_profile" || permission == "view_students";
    }
    
    std::string getDepartment() const { return department; }
    std::string getPosition() const { return position; }
    
    void addTeachingSubject(const std::string& subject) {
        teachingSubjects.push_back(subject);
    }
};

/**
 * Класс администратора - наследует от AbstractUser
 */
class Administrator : public AbstractUser {
private:
    std::string role;
    int accessLevel;
    
public:
    Administrator(const std::string& id, const std::string& name, const std::string& email,
                  const std::string& role, int accessLevel)
        : AbstractUser(id, name, email), role(role), accessLevel(accessLevel) {}
    
    std::string getUserType() const override {
        return "Administrator";
    }
    
    std::string getDisplayInfo() const override {
        return getName() + " - " + role + " (уровень доступа: " + std::to_string(accessLevel) + ")";
    }
    
    bool hasPermission(const std::string& permission) const override {
        // Администраторы имеют все права
        return true;
    }
    
    std::string getRole() const { return role; }
    int getAccessLevel() const { return accessLevel; }
};

// ========================================
// 3. ПОЛИМОРФИЗМ - Конкретные сервисы
// ========================================

/**
 * Сервис аутентификации - наследует от AbstractApiService
 */
class AuthenticationService : public AbstractApiService {
private:
    std::string username;
    std::string password;
    
protected:
    bool validateRequest() const override {
        return !username.empty() && !password.empty();
    }
    
    std::string buildEndpoint() const override {
        return baseUrl + "/auth/login";
    }
    
    void logRequest() const override {
        std::cout << "AuthService: Logging in user " << username << std::endl;
    }
    
    bool executeRequest(const std::string& endpoint) override {
        // Имитация HTTP запроса
        std::cout << "POST " << endpoint << " with credentials" << std::endl;
        return true; // Имитируем успешный ответ
    }
    
public:
    AuthenticationService(const std::string& baseUrl) : AbstractApiService(baseUrl) {}
    
    void setCredentials(const std::string& user, const std::string& pass) {
        username = user;
        password = pass;
    }
};

/**
 * Сервис получения данных студента
 */
class StudentDataService : public AbstractApiService {
private:
    std::string studentId;
    
protected:
    bool validateRequest() const override {
        return !studentId.empty() && !authToken.empty();
    }
    
    std::string buildEndpoint() const override {
        return baseUrl + "/students/" + studentId;
    }
    
    void logRequest() const override {
        std::cout << "StudentDataService: Fetching data for student " << studentId << std::endl;
    }
    
    bool executeRequest(const std::string& endpoint) override {
        std::cout << "GET " << endpoint << " with token: " << authToken << std::endl;
        return true;
    }
    
public:
    StudentDataService(const std::string& baseUrl) : AbstractApiService(baseUrl) {}
    
    void setStudentId(const std::string& id) {
        studentId = id;
    }
};

// ========================================
// 4. ИНКАПСУЛЯЦИЯ - Менеджер пользователей
// ========================================

/**
 * Менеджер пользователей - демонстрирует инкапсуляцию
 * Скрывает внутреннюю структуру данных и предоставляет контролируемый доступ
 */
class UserManager {
private:
    std::vector<std::unique_ptr<AbstractUser>> users;
    std::unique_ptr<AbstractUser> currentUser;
    
    // Приватные методы - часть инкапсуляции
    bool isValidUserId(const std::string& id) const {
        return !id.empty() && id.length() >= 3;
    }
    
    AbstractUser* findUserById(const std::string& id) const {
        for (const auto& user : users) {
            if (user->getId() == id) {
                return user.get();
            }
        }
        return nullptr;
    }
    
public:
    UserManager() = default;
    
    // Публичные методы для контролируемого доступа к данным
    bool addUser(std::unique_ptr<AbstractUser> user) {
        if (!user || !isValidUserId(user->getId())) {
            return false;
        }
        
        // Проверяем, что пользователь с таким ID не существует
        if (findUserById(user->getId()) != nullptr) {
            return false;
        }
        
        users.push_back(std::move(user));
        return true;
    }
    
    bool setCurrentUser(const std::string& userId) {
        AbstractUser* user = findUserById(userId);
        if (user) {
            // Создаем копию пользователя (демонстрация управления памятью)
            if (user->getUserType() == "Student") {
                Student* student = dynamic_cast<Student*>(user);
                if (student) {
                    currentUser = std::make_unique<Student>(*student);
                    return true;
                }
            }
            // Аналогично для других типов пользователей...
        }
        return false;
    }
    
    AbstractUser* getCurrentUser() const {
        return currentUser.get();
    }
    
    std::vector<std::string> getUsersList() const {
        std::vector<std::string> userList;
        for (const auto& user : users) {
            userList.push_back(user->getDisplayInfo());
        }
        return userList;
    }
    
    size_t getUserCount() const {
        return users.size();
    }
    
    // Демонстрация полиморфизма
    void printAllUsers() const {
        std::cout << "=== Список пользователей ===" << std::endl;
        for (const auto& user : users) {
            std::cout << user->getUserType() << ": " << user->getDisplayInfo() << std::endl;
        }
    }
    
    bool checkUserPermission(const std::string& userId, const std::string& permission) const {
        AbstractUser* user = findUserById(userId);
        return user ? user->hasPermission(permission) : false;
    }
};

// ========================================
// 5. ПАТТЕРНЫ ПРОЕКТИРОВАНИЯ
// ========================================

/**
 * Singleton pattern для настроек приложения
 */
class AppConfig {
private:
    static std::unique_ptr<AppConfig> instance;
    static std::mutex mutex_;
    
    std::string apiBaseUrl;
    std::string appVersion;
    bool debugMode;
    
    // Приватный конструктор для Singleton
    AppConfig() : apiBaseUrl("https://iis.bsuir.by/api/v1"), appVersion("1.0.0"), debugMode(true) {}
    
public:
    AppConfig(const AppConfig&) = delete;
    AppConfig& operator=(const AppConfig&) = delete;
    
    static AppConfig* getInstance() {
        std::lock_guard<std::mutex> lock(mutex_);
        if (instance == nullptr) {
            instance = std::unique_ptr<AppConfig>(new AppConfig());
        }
        return instance.get();
    }
    
    std::string getApiBaseUrl() const { return apiBaseUrl; }
    std::string getAppVersion() const { return appVersion; }
    bool isDebugMode() const { return debugMode; }
    
    void setApiBaseUrl(const std::string& url) { apiBaseUrl = url; }
    void setDebugMode(bool debug) { debugMode = debug; }
};

/**
 * Observer pattern для уведомлений
 */
class Observer {
public:
    virtual ~Observer() = default;
    virtual void onUserLoggedIn(const AbstractUser* user) = 0;
    virtual void onUserLoggedOut() = 0;
    virtual void onDataUpdated(const std::string& dataType) = 0;
};

class Subject {
private:
    std::vector<Observer*> observers;
    
public:
    void addObserver(Observer* observer) {
        observers.push_back(observer);
    }
    
    void removeObserver(Observer* observer) {
        observers.erase(
            std::remove(observers.begin(), observers.end(), observer),
            observers.end()
        );
    }
    
protected:
    void notifyUserLoggedIn(const AbstractUser* user) {
        for (auto* observer : observers) {
            observer->onUserLoggedIn(user);
        }
    }
    
    void notifyUserLoggedOut() {
        for (auto* observer : observers) {
            observer->onUserLoggedOut();
        }
    }
    
    void notifyDataUpdated(const std::string& dataType) {
        for (auto* observer : observers) {
            observer->onDataUpdated(dataType);
        }
    }
};

/**
 * Factory pattern для создания пользователей
 */
class UserFactory {
public:
    enum class UserType {
        STUDENT,
        TEACHER,
        ADMINISTRATOR
    };
    
    static std::unique_ptr<AbstractUser> createUser(
        UserType type,
        const std::string& id,
        const std::string& name,
        const std::string& email,
        const std::vector<std::string>& additionalParams = {}
    ) {
        switch (type) {
            case UserType::STUDENT:
                if (additionalParams.size() >= 2) {
                    return std::make_unique<Student>(
                        id, name, email,
                        additionalParams[0], // studentNumber
                        additionalParams[1], // group
                        additionalParams.size() > 2 ? std::stoi(additionalParams[2]) : 1 // course
                    );
                }
                break;
                
            case UserType::TEACHER:
                if (additionalParams.size() >= 2) {
                    return std::make_unique<Teacher>(
                        id, name, email,
                        additionalParams[0], // department
                        additionalParams[1]  // position
                    );
                }
                break;
                
            case UserType::ADMINISTRATOR:
                if (additionalParams.size() >= 2) {
                    return std::make_unique<Administrator>(
                        id, name, email,
                        additionalParams[0], // role
                        additionalParams.size() > 1 ? std::stoi(additionalParams[1]) : 1 // accessLevel
                    );
                }
                break;
        }
        return nullptr;
    }
};

} // namespace BSUIR

#endif /* BSUIROOPDemo_hpp */