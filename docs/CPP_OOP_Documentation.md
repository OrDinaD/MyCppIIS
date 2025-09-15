# API Documentation - cPPiIS

## C++ Core Classes Documentation

Эта документация описывает основные классы C++ бэкенда приложения cPPiIS, демонстрирующие принципы объектно-ориентированного программирования.

## 📚 Основные принципы ООП

### 1. Абстракция (Abstraction)

#### `AbstractUser` - Абстрактный пользователь
```cpp
class AbstractUser {
protected:
    std::string id;
    std::string name;
    std::string email;
    
public:
    AbstractUser(const std::string& id, const std::string& name, const std::string& email);
    virtual ~AbstractUser() = default;
    
    // Чисто виртуальные методы - обязательны для реализации
    virtual std::string getUserType() const = 0;
    virtual std::string getDisplayInfo() const = 0;
    virtual bool hasPermission(const std::string& permission) const = 0;
    
    // Обычные виртуальные методы с реализацией по умолчанию
    virtual std::string getId() const;
    virtual std::string getName() const;
    virtual std::string getEmail() const;
};
```

**Демонстрирует:**
- **Абстракция**: Скрывает детали реализации за интерфейсом
- **Полиморфизм**: Виртуальные методы для runtime binding
- **Инкапсуляция**: Защищенные члены доступны только наследникам

#### `AbstractApiService` - Абстрактный API сервис
```cpp
class AbstractApiService {
protected:
    std::string baseUrl;
    std::string authToken;
    
    // Template Method pattern - определяет алгоритм
    virtual bool validateRequest() const = 0;
    virtual std::string buildEndpoint() const = 0;
    virtual void logRequest() const = 0;
    
public:
    // Template Method - общий алгоритм для всех API запросов
    virtual bool makeRequest() final;
    
protected:
    virtual bool executeRequest(const std::string& endpoint) = 0;
};
```

**Демонстрирует:**
- **Template Method Pattern**: `makeRequest()` определяет алгоритм
- **Абстракция**: Абстрактные шаги реализуются в наследниках

### 2. Наследование (Inheritance)

#### `Student` - Класс студента
```cpp
class Student : public AbstractUser {
private:
    std::string studentNumber;
    std::string group;
    int course;
    std::vector<std::string> subjects;
    
public:
    Student(const std::string& id, const std::string& name, const std::string& email,
            const std::string& studentNumber, const std::string& group, int course);
    
    // Реализация абстрактных методов
    std::string getUserType() const override { return "Student"; }
    std::string getDisplayInfo() const override;
    bool hasPermission(const std::string& permission) const override;
    
    // Специфичные для студента методы
    std::string getStudentNumber() const;
    std::string getGroup() const;
    int getCourse() const;
    void addSubject(const std::string& subject);
};
```

**Демонстрирует:**
- **Наследование**: Расширяет функциональность `AbstractUser`
- **Полиморфизм**: Переопределяет виртуальные методы
- **Специализация**: Добавляет специфичную для студента функциональность

#### `Teacher` и `Administrator`
Аналогично наследуют от `AbstractUser`, каждый со своей специализацией:
- **Teacher**: Управление предметами и студентами
- **Administrator**: Полные права доступа к системе

### 3. Полиморфизм (Polymorphism)

#### Пример использования полиморфизма:
```cpp
// Хранение разных типов пользователей в одном контейнере
std::vector<std::unique_ptr<AbstractUser>> users;
users.push_back(std::make_unique<Student>(...));
users.push_back(std::make_unique<Teacher>(...));
users.push_back(std::make_unique<Administrator>(...));

// Полиморфный вызов методов
for (const auto& user : users) {
    std::cout << user->getUserType() << ": " << user->getDisplayInfo() << std::endl;
    
    if (user->hasPermission("edit_grades")) {
        std::cout << "Can edit grades" << std::endl;
    }
}
```

**Демонстрирует:**
- **Runtime Polymorphism**: Вызов методов зависит от реального типа объекта
- **Виртуальные методы**: Обеспечивают правильный выбор реализации
- **Unified Interface**: Единый интерфейс для разных типов

### 4. Инкапсуляция (Encapsulation)

#### `UserManager` - Менеджер пользователей
```cpp
class UserManager {
private:
    std::vector<std::unique_ptr<AbstractUser>> users;
    std::unique_ptr<AbstractUser> currentUser;
    
    // Приватные методы - часть инкапсуляции
    bool isValidUserId(const std::string& id) const;
    AbstractUser* findUserById(const std::string& id) const;
    
public:
    // Публичные методы для контролируемого доступа
    bool addUser(std::unique_ptr<AbstractUser> user);
    bool setCurrentUser(const std::string& userId);
    AbstractUser* getCurrentUser() const;
    std::vector<std::string> getUsersList() const;
    size_t getUserCount() const;
    bool checkUserPermission(const std::string& userId, const std::string& permission) const;
};
```

**Демонстрирует:**
- **Сокрытие данных**: Приватные члены недоступны извне
- **Контролируемый доступ**: Публичные методы обеспечивают безопасный интерфейс
- **Валидация**: Внутренние методы обеспечивают целостность данных

## 🎨 Паттерны проектирования

### 1. Singleton Pattern
```cpp
class AppConfig {
private:
    static std::unique_ptr<AppConfig> instance;
    static std::mutex mutex_;
    
    // Приватный конструктор
    AppConfig();
    
public:
    AppConfig(const AppConfig&) = delete;
    AppConfig& operator=(const AppConfig&) = delete;
    
    static AppConfig* getInstance();
    
    std::string getApiBaseUrl() const;
    bool isDebugMode() const;
};
```

### 2. Observer Pattern
```cpp
class Observer {
public:
    virtual void onUserLoggedIn(const AbstractUser* user) = 0;
    virtual void onUserLoggedOut() = 0;
    virtual void onDataUpdated(const std::string& dataType) = 0;
};

class Subject {
private:
    std::vector<Observer*> observers;
    
public:
    void addObserver(Observer* observer);
    void removeObserver(Observer* observer);
    
protected:
    void notifyUserLoggedIn(const AbstractUser* user);
    void notifyUserLoggedOut();
    void notifyDataUpdated(const std::string& dataType);
};
```

### 3. Factory Pattern
```cpp
class UserFactory {
public:
    enum class UserType { STUDENT, TEACHER, ADMINISTRATOR };
    
    static std::unique_ptr<AbstractUser> createUser(
        UserType type,
        const std::string& id,
        const std::string& name,
        const std::string& email,
        const std::vector<std::string>& additionalParams = {}
    );
};
```

### 4. Template Method Pattern
```cpp
// В AbstractApiService
bool AbstractApiService::makeRequest() final {
    if (!validateRequest()) {
        return false;
    }
    
    logRequest();
    std::string endpoint = buildEndpoint();
    return executeRequest(endpoint);
}
```

## 🔧 Современные практики C++

### 1. RAII и Smart Pointers
```cpp
class HTTPClient {
private:
    std::unique_ptr<Implementation> impl; // Автоматическое управление памятью
    
public:
    HTTPClient(); // Инициализация ресурсов
    ~HTTPClient(); // Автоматическая очистка
    
    // Запрет копирования
    HTTPClient(const HTTPClient&) = delete;
    HTTPClient& operator=(const HTTPClient&) = delete;
    
    // Разрешение перемещения
    HTTPClient(HTTPClient&&) = default;
    HTTPClient& operator=(HTTPClient&&) = default;
};
```

### 2. Const Correctness
```cpp
class UserManager {
public:
    // Const методы не изменяют состояние объекта
    size_t getUserCount() const;
    AbstractUser* getCurrentUser() const;
    bool checkUserPermission(const std::string& userId, const std::string& permission) const;
    
private:
    // Const методы для внутреннего использования
    bool isValidUserId(const std::string& id) const;
    AbstractUser* findUserById(const std::string& id) const;
};
```

### 3. Move Semantics
```cpp
// Эффективное перемещение объектов
bool UserManager::addUser(std::unique_ptr<AbstractUser> user) {
    if (!user || !isValidUserId(user->getId())) {
        return false;
    }
    
    users.push_back(std::move(user)); // Перемещение вместо копирования
    return true;
}
```

## 🔐 Безопасность и лучшие практики

### 1. Безопасное хранение токенов
```cpp
class SecureTokenStorage {
private:
    class SecureString {
        std::unique_ptr<char[]> data;
        size_t length;
    public:
        ~SecureString() {
            if (data && length > 0) {
                std::memset(data.get(), 0, length); // Обнуление памяти
            }
        }
    };
    
    std::unique_ptr<SecureString> accessToken;
    std::unique_ptr<SecureString> refreshToken;
    
public:
    std::optional<std::string> getAccessToken() const;
    void clearTokens(); // Безопасная очистка
};
```

### 2. Dependency Injection вместо Singleton
```cpp
// Старый подход - проблематичен для тестирования
class OldService {
    AppConfig* config = AppConfig::getInstance(); // Жесткая зависимость
};

// Новый подход - легко тестируется
class NewService {
    std::unique_ptr<IConfigProvider> config; // Инжектируемая зависимость
public:
    explicit NewService(std::unique_ptr<IConfigProvider> configProvider);
};
```

## 📊 Примеры использования

### Создание и использование пользователей
```cpp
// Создание через Factory
auto student = UserFactory::createUser(
    UserFactory::UserType::STUDENT,
    "12345", "Иван Иванов", "ivan@example.com",
    {"20220001", "ИИТ-21", "2"}
);

auto teacher = UserFactory::createUser(
    UserFactory::UserType::TEACHER,
    "67890", "Петр Петров", "petr@example.com",
    {"Информатика", "Доцент"}
);

// Добавление в менеджер
UserManager manager;
manager.addUser(std::move(student));
manager.addUser(std::move(teacher));

// Полиморфное использование
manager.printAllUsers(); // Вызывает виртуальные методы
```

### Работа с API сервисами
```cpp
// Создание через Factory с DI
auto config = ConfigProviderFactory::createDevelopmentConfig();
auto apiService = ApiServiceFactory::createCustomService(std::move(config));

// Использование с Observer pattern
class UIObserver : public Observer {
public:
    void onUserLoggedIn(const AbstractUser* user) override {
        std::cout << "UI: User logged in - " << user->getDisplayInfo() << std::endl;
    }
};

UIObserver uiObserver;
apiService->addObserver(&uiObserver);

// Аутентификация
apiService->login("student_number", "password", [](const auto& result) {
    if (result.success) {
        std::cout << "Login successful!" << std::endl;
    }
});
```

---

Эта документация демонстрирует комплексное применение принципов ООП и современных практик C++ в реальном проекте, что является идеальным примером для курсовой работы по объектно-ориентированному программированию.