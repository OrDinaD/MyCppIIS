# 📱 cPPiIS - Курсовой проект по ООП

<div align="center">

![iOS](https://img.shields.io/badge/iOS-18.6-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-16-brightgreen.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![C++](https://img.shields.io/badge/C++-17/20-red.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

## 📋 Описание проекта

**cPPiIS** (C++ Powered iOS Information System) - это мобильное iOS приложение, интегрированное с информационной системой БГУИР, демонстрирующее профессиональное применение объектно-ориентированного программирования на современном C++.

> **🎓 Курсовая работа по дисциплине "Объектно-ориентированное программирование"**  
> Проект создан для демонстрации глубокого понимания принципов ООП, паттернов проектирования, современных практик разработки на C++ и интеграции с iOS экосистемой.

## 🎯 Цели проекта

- Демонстрация **4 основных принципов ООП**: инкапсуляция, наследование, полиморфизм, абстракция
- Применение **классических паттернов проектирования**: Singleton, Factory, Observer, Template Method
- Использование **современных практик C++**: RAII, smart pointers, move semantics
- Реализация **архитектурных паттернов**: Dependency Injection, Repository Pattern
- Обеспечение **безопасности**: secure memory management, safe token storage

## 🏗️ Архитектура

## 📁 Структура проекта

```
cPPiIS/
├── 📁 Core/                      # C++ бизнес-логика
│   ├── 🧬 BSUIROOPDemo.hpp      # Демонстрация ООП принципов
│   ├── 🌐 ApiService.hpp        # Главный API сервис
│   ├── 📡 HTTPClient.hpp        # HTTP клиент
│   ├── ⚙️ IConfigProvider.hpp   # Интерфейс конфигурации (DI)
│   ├── 🔐 SecureTokenStorage.hpp # Безопасное хранение токенов
│   ├── 📊 Models.hpp           # Модели данных
│   └── 🔧 JSONParser.hpp       # JSON парсер
├── 📁 Bridge/                   # Objective-C++ мосты
│   ├── 🌉 BSUIRAPIBridge.mm    # Мост Swift ↔ C++
│   ├── 🔄 HTTPClientBridge.mm  # HTTP клиент мост
│   └── 📝 BSUIRLogBridge.mm    # Логирование мост
├── 📁 Views/                    # SwiftUI интерфейс
│   ├── 🔐 LoginView.swift      # Экран входа
│   ├── 👤 ProfileView.swift    # Профиль пользователя
│   ├── 📋 MarkbookView.swift   # Зачетная книжка
│   ├── 👥 GroupInfoView.swift  # Информация о группе
│   └── 🧭 MainNavigationView.swift # Навигация
├── 📁 Models/                   # Swift модели (пустая - используем C++)
├── 📄 test_api*.py             # Python тесты API
├── 📜 *.md                     # Документация
└── 🔧 Config.h                 # Конфигурация проекта
```

## 🛠️ Технологический стек

### Основные технологии
- **🍎 Swift + SwiftUI**: Пользовательский интерфейс
- **⚡ C++17/20**: Бизнес-логика и алгоритмы
- **🔄 Objective-C++**: Мост между Swift и C++
- **🌐 HTTP/REST**: Сетевое взаимодействие
- **🔒 Keychain Services**: Безопасное хранение

### Инструменты разработки
- **🔨 Xcode 16**: Основная IDE
- **🐍 Python**: Тестирование API
- **📋 Doxygen**: Генерация документации
- **🔍 Static Analysis**: Встроенные анализаторы Xcode

## 🔧 Применяемые принципы ООП

### 1. **Абстракция**
```cpp
// Абстрактный базовый класс для пользователей
class AbstractUser {
public:
    virtual ~AbstractUser() = default;
    virtual std::string getUserType() const = 0;
    virtual std::string getDisplayInfo() const = 0;
    virtual bool hasPermission(const std::string& permission) const = 0;
};

// Абстрактный API сервис с Template Method pattern
class AbstractApiService {
protected:
    virtual bool validateRequest() const = 0;
    virtual std::string buildEndpoint() const = 0;
    virtual void logRequest() const = 0;
public:
    virtual bool makeRequest() final; // Template Method
};
```

### 2. **Наследование**
```cpp
// Конкретные классы пользователей
class Student : public AbstractUser {
    std::string getUserType() const override { return "Student"; }
    bool hasPermission(const std::string& permission) const override;
};

class Teacher : public AbstractUser {
    std::string getUserType() const override { return "Teacher"; }
    bool hasPermission(const std::string& permission) const override;
};

// API сервис наследует от абстрактного и реализует Subject для Observer pattern
class ApiService : public AbstractApiService, public Subject {
protected:
    bool validateRequest() const override;
    std::string buildEndpoint() const override;
    void logRequest() const override;
};
```

### 3. **Полиморфизм**
```cpp
// Полиморфное использование пользователей
std::vector<std::unique_ptr<AbstractUser>> users;
users.push_back(std::make_unique<Student>(...));
users.push_back(std::make_unique<Teacher>(...));

for (const auto& user : users) {
    std::cout << user->getUserType() << ": " << user->getDisplayInfo() << std::endl;
    // Виртуальные методы вызываются в зависимости от реального типа
}
```

### 4. **Инкапсуляция**
```cpp
class SecureTokenStorage {
private:
    class SecureString {
        std::unique_ptr<char[]> data;
        size_t length;
    public:
        explicit SecureString(const std::string& value);
        ~SecureString(); // Автоматическая очистка памяти
    };
    
    std::unique_ptr<SecureString> accessToken;
    std::unique_ptr<SecureString> refreshToken;
    
public:
    std::optional<std::string> getAccessToken() const;
    void storeTokens(const std::string& access, const std::string& refresh);
    void clearTokens(); // Безопасная очистка
};
```

## 🎨 Применяемые паттерны проектирования

### 1. **Factory Pattern**
```cpp
class ApiServiceFactory {
public:
    static std::unique_ptr<ApiService> createProductionService();
    static std::unique_ptr<ApiService> createDevelopmentService();
    static std::unique_ptr<ApiService> createTestService();
};

class UserFactory {
public:
    static std::unique_ptr<AbstractUser> createUser(
        UserType type, 
        const std::string& id,
        const std::vector<std::string>& params
    );
};
```

### 2. **Dependency Injection (замена Singleton)**
```cpp
// СТАРЫЙ подход (Singleton - проблематичен для тестирования)
class AppConfig {
    static AppConfig* getInstance(); // Плохо для юнит-тестов
};

// НОВЫЙ подход (Dependency Injection)
class IConfigProvider {
public:
    virtual std::string getApiBaseUrl() const = 0;
    virtual bool isDebugMode() const = 0;
};

class ApiService {
    std::unique_ptr<IConfigProvider> configProvider; // Инжектируемая зависимость
public:
    explicit ApiService(std::unique_ptr<IConfigProvider> config);
};
```

### 3. **Observer Pattern**
```cpp
class Observer {
public:
    virtual void onUserLoggedIn(const AbstractUser* user) = 0;
    virtual void onUserLoggedOut() = 0;
    virtual void onDataUpdated(const std::string& dataType) = 0;
};

class Subject {
    std::vector<Observer*> observers;
protected:
    void notifyUserLoggedIn(const AbstractUser* user);
    void notifyUserLoggedOut();
};
```

### 4. **Template Method Pattern**
```cpp
class AbstractApiService {
public:
    // Template Method - определяет алгоритм
    bool makeRequest() final {
        if (!validateRequest()) return false;
        logRequest();
        std::string endpoint = buildEndpoint();
        return executeRequest(endpoint);
    }
protected:
    // Абстрактные шаги - реализуются в наследниках
    virtual bool validateRequest() const = 0;
    virtual std::string buildEndpoint() const = 0;
    virtual void logRequest() const = 0;
};
```

## 🔐 Современные практики C++

### 1. **RAII (Resource Acquisition Is Initialization)**
```cpp
class HTTPClient {
public:
    HTTPClient(); // Инициализация ресурсов
    ~HTTPClient(); // Автоматическая очистка
    
    // Запрет копирования для безопасности
    HTTPClient(const HTTPClient&) = delete;
    HTTPClient& operator=(const HTTPClient&) = delete;
    
    // Разрешение перемещения для эффективности
    HTTPClient(HTTPClient&&) = default;
    HTTPClient& operator=(HTTPClient&&) = default;
};
```

### 2. **Smart Pointers**
```cpp
// Использование unique_ptr для автоматического управления памятью
std::unique_ptr<HTTPClient> httpClient;
std::unique_ptr<IConfigProvider> configProvider;

// Использование shared_ptr для разделяемых ресурсов
std::shared_ptr<UserManager> userManager;

// НЕТ raw pointers - все ресурсы управляются автоматически
```

### 3. **Modern C++ Features**
```cpp
// Использование std::optional вместо nullable pointers
std::optional<std::string> getAccessToken() const;

// Move semantics для эффективности
SecureTokenStorage(SecureTokenStorage&& other) noexcept;

// Default parameters вместо множественных перегрузок
void post(const std::string& endpoint,
          const std::string& body,
          ResponseCallback callback,
          const std::map<std::string, std::string>& headers = {});

// Constexpr для compile-time вычислений
constexpr bool isValidStatusCode(int code) noexcept {
    return code >= 200 && code < 300;
}
```

### 4. **Безопасность и Const Correctness**
```cpp
class SecureTokenStorage {
public:
    // Const методы не изменяют состояние
    std::optional<std::string> getAccessToken() const;
    bool hasValidTokens() const noexcept;
    bool isTokenExpired() const noexcept;
    
    // Безопасная очистка памяти
    ~SecureTokenStorage() {
        clearTokens(); // Обнуляет чувствительные данные
    }
};
```

## 📊 Улучшения архитектуры

### До рефакторинга:
- ❌ Множественные перегрузки методов в HTTPClient
- ❌ Singleton паттерн (проблемы с тестированием)
- ❌ Закомментированный код и технический долг
- ❌ Хранение реальных паролей в коде
- ❌ Отсутствие связи между демо-кодом и реальным функционалом

### После рефакторинга:
- ✅ Упрощенный HTTPClient с default parameters
- ✅ Dependency Injection вместо Singleton
- ✅ Чистый код без комментариев и .bak файлов
- ✅ Безопасное хранение токенов с автоматической очисткой
- ✅ Интеграция всех ООП принципов в реальный функционал
- ✅ Полная документация с Doxygen комментариями

## 🚀 Быстрый старт

### Системные требования

- **macOS**: 14.0+ (Sonoma)
- **Xcode**: 16.0+
- **iOS Deployment Target**: 18.6+
- **Swift**: 5.9+
- **C++ Standard**: 17/20

### Установка и запуск

1. **Клонировать репозиторий**
   ```bash
   git clone https://github.com/OrDinaD/MyCppIIS.git
   cd cPPiIS
   ```

2. **Открыть проект в Xcode**
   ```bash
   open cPPiIS.xcodeproj
   ```

3. **Настроить команду разработчика**
   - В Xcode перейдите в настройки проекта
   - Выберите вашу Developer Team
   - Обновите Bundle Identifier если необходимо

4. **Сборка и запуск**
   - Выберите симулятор iPhone 16 Pro или физическое устройство
   - Нажмите `⌘+R` для сборки и запуска

### Для тестирования API

1. **Настройте Python environment**
   ```bash
   python3 -m pip install requests
   ```

2. **Запустите тесты**
   ```bash
   python3 test_api.py           # Базовые тесты
   python3 test_api_detailed.py  # Подробные тесты
   python3 test_api_sessions.py  # Тесты сессий
   ```

## 🧪 Тестирование

### API тестирование
```bash
python3 test_api.py
```

### Демонстрация ООП принципов
Файл `BSUIROOPDemo.hpp` содержит полную демонстрацию всех принципов ООП с примерами использования.

## 📚 Документация

Проект использует **Doxygen** для генерации документации:

```bash
doxygen Doxyfile  # Генерация HTML документации
```

Все классы и методы содержат подробные комментарии, объясняющие применяемые принципы ООП и паттерны.

## 🎓 Образовательная ценность

Этот проект демонстрирует:

1. **Теоретические знания ООП**: все 4 принципа с практическими примерами
2. **Паттерны проектирования**: 5+ классических паттернов в реальном применении
3. **Современный C++**: RAII, smart pointers, move semantics, constexpr
4. **Архитектурные решения**: DI, clean architecture, secure coding
5. **Практические навыки**: интеграция C++ с iOS, networking, безопасность

## 📋 Заключение

Проект **cPPiIS** успешно демонстрирует глубокое понимание объектно-ориентированного программирования на C++. Код написан с использованием современных практик, паттернов проектирования и принципов безопасности, что делает его отличным примером для курсовой работы по ООП.

---

**👨‍💻 Автор**: Владислав Орлов  
**📚 Дисциплина**: Объектно-ориентированное программирование  
**🏫 Учебное заведение**: БГУИР  
**📅 Год**: 2025

<div align="center">

**Проект демонстрирует профессиональное владение современным C++ и принципами ООП**

[![GitHub](https://img.shields.io/badge/GitHub-Repository-black?logo=github)](https://github.com/OrDinaD/MyCppIIS)

</div>