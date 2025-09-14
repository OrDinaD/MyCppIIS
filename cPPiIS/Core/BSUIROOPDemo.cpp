//
//  BSUIROOPDemo.cpp
//  Демонстрация использования ООП принципов
//

#include "BSUIROOPDemo.hpp"
#include <iostream>
#include <mutex>

namespace BSUIR {

// Статические члены Singleton
std::unique_ptr<AppConfig> AppConfig::instance = nullptr;
std::mutex AppConfig::mutex_;

/**
 * Демонстрационный класс Observer
 */
class UIUpdateObserver : public Observer {
private:
    std::string observerName;
    
public:
    UIUpdateObserver(const std::string& name) : observerName(name) {}
    
    void onUserLoggedIn(const AbstractUser* user) override {
        std::cout << "[" << observerName << "] Пользователь вошел в систему: " 
                  << user->getDisplayInfo() << std::endl;
    }
    
    void onUserLoggedOut() override {
        std::cout << "[" << observerName << "] Пользователь вышел из системы" << std::endl;
    }
    
    void onDataUpdated(const std::string& dataType) override {
        std::cout << "[" << observerName << "] Обновлены данные: " << dataType << std::endl;
    }
};

/**
 * Основной класс приложения, демонстрирующий все ООП принципы
 */
class BSUIRApplication : public Subject {
private:
    UserManager userManager;
    std::unique_ptr<AuthenticationService> authService;
    std::unique_ptr<StudentDataService> studentService;
    std::vector<std::unique_ptr<UIUpdateObserver>> observers;
    
public:
    BSUIRApplication() {
        // Инициализация сервисов с использованием Singleton
        AppConfig* config = AppConfig::getInstance();
        authService = std::make_unique<AuthenticationService>(config->getApiBaseUrl());
        studentService = std::make_unique<StudentDataService>(config->getApiBaseUrl());
        
        // Создание наблюдателей
        observers.push_back(std::make_unique<UIUpdateObserver>("MainUI"));
        observers.push_back(std::make_unique<UIUpdateObserver>("NotificationCenter"));
        
        // Регистрация наблюдателей
        for (auto& observer : observers) {
            addObserver(observer.get());
        }
    }
    
    void demonstrateOOP() {
        std::cout << "========================================" << std::endl;
        std::cout << "ДЕМОНСТРАЦИЯ ООП ПРИНЦИПОВ В C++" << std::endl;
        std::cout << "========================================" << std::endl;
        
        // 1. ДЕМОНСТРАЦИЯ FACTORY PATTERN
        std::cout << "\n1. FACTORY PATTERN - Создание пользователей:" << std::endl;
        
        auto student = UserFactory::createUser(
            UserFactory::UserType::STUDENT,
            "1", "Иван Иванов", "ivan@student.bsuir.by",
            {"42850012", "ИИТ-31", "3"}
        );
        
        auto teacher = UserFactory::createUser(
            UserFactory::UserType::TEACHER,
            "2", "Петр Петров", "petrov@bsuir.by",
            {"Кафедра ИИТ", "Доцент"}
        );
        
        auto admin = UserFactory::createUser(
            UserFactory::UserType::ADMINISTRATOR,
            "3", "Анна Админова", "admin@bsuir.by",
            {"Системный администратор", "10"}
        );
        
        // 2. ДЕМОНСТРАЦИЯ ИНКАПСУЛЯЦИИ
        std::cout << "\n2. ИНКАПСУЛЯЦИЯ - Управление пользователями:" << std::endl;
        
        userManager.addUser(std::move(student));
        userManager.addUser(std::move(teacher));
        userManager.addUser(std::move(admin));
        
        std::cout << "Всего пользователей: " << userManager.getUserCount() << std::endl;
        
        // 3. ДЕМОНСТРАЦИЯ ПОЛИМОРФИЗМА
        std::cout << "\n3. ПОЛИМОРФИЗМ - Вывод информации о пользователях:" << std::endl;
        userManager.printAllUsers();
        
        // 4. ДЕМОНСТРАЦИЯ НАСЛЕДОВАНИЯ И ВИРТУАЛЬНЫХ ФУНКЦИЙ
        std::cout << "\n4. НАСЛЕДОВАНИЕ - Проверка прав доступа:" << std::endl;
        
        std::vector<std::string> permissions = {"view_grades", "edit_grades", "view_students"};
        std::vector<std::string> userIds = {"1", "2", "3"};
        
        for (const auto& userId : userIds) {
            for (const auto& permission : permissions) {
                bool hasAccess = userManager.checkUserPermission(userId, permission);
                std::cout << "Пользователь " << userId << " -> " << permission 
                          << ": " << (hasAccess ? "ДА" : "НЕТ") << std::endl;
            }
            std::cout << std::endl;
        }
        
        // 5. ДЕМОНСТРАЦИЯ TEMPLATE METHOD PATTERN
        std::cout << "\n5. TEMPLATE METHOD PATTERN - API запросы:" << std::endl;
        
        authService->setCredentials("42850012", "password123");
        std::cout << "Аутентификация:" << std::endl;
        authService->makeRequest();
        
        std::cout << "\nПолучение данных студента:" << std::endl;
        studentService->setAuthToken("jwt_token_here");
        studentService->setStudentId("42850012");
        studentService->makeRequest();
        
        // 6. ДЕМОНСТРАЦИЯ OBSERVER PATTERN
        std::cout << "\n6. OBSERVER PATTERN - Уведомления:" << std::endl;
        
        if (userManager.setCurrentUser("1")) {
            notifyUserLoggedIn(userManager.getCurrentUser());
        }
        
        notifyDataUpdated("Оценки");
        notifyUserLoggedOut();
        
        // 7. ДЕМОНСТРАЦИЯ SINGLETON PATTERN
        std::cout << "\n7. SINGLETON PATTERN - Конфигурация приложения:" << std::endl;
        AppConfig* config = AppConfig::getInstance();
        std::cout << "API URL: " << config->getApiBaseUrl() << std::endl;
        std::cout << "Версия приложения: " << config->getAppVersion() << std::endl;
        std::cout << "Режим отладки: " << (config->isDebugMode() ? "ВКЛ" : "ВЫКЛ") << std::endl;
        
        // 8. ДЕМОНСТРАЦИЯ АБСТРАКЦИИ
        std::cout << "\n8. АБСТРАКЦИЯ - Работа с абстрактными классами:" << std::endl;
        AbstractUser* currentUser = userManager.getCurrentUser();
        if (currentUser) {
            std::cout << "Текущий пользователь:" << std::endl;
            std::cout << "- Тип: " << currentUser->getUserType() << std::endl;
            std::cout << "- Информация: " << currentUser->getDisplayInfo() << std::endl;
            std::cout << "- Базовая информация: " << currentUser->getBasicInfo() << std::endl;
        }
        
        std::cout << "\n========================================" << std::endl;
        std::cout << "ДЕМОНСТРАЦИЯ ЗАВЕРШЕНА" << std::endl;
        std::cout << "========================================" << std::endl;
    }
    
    UserManager& getUserManager() { return userManager; }
    AuthenticationService& getAuthService() { return *authService; }
    StudentDataService& getStudentService() { return *studentService; }
};

/**
 * Функция для демонстрации всех ООП принципов
 */
void demonstrateOOPPrinciples() {
    BSUIRApplication app;
    app.demonstrateOOP();
}

} // namespace BSUIR