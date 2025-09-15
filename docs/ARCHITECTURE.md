# 🚀 Архитектурные решения cPPiIS

## 📐 Общие принципы архитектуры

### 🎯 Архитектурная философия
Проект построен на принципах **Clean Architecture** с акцентом на демонстрацию ООП принципов:

1. **Separation of Concerns** - Четкое разделение ответственности
2. **Dependency Inversion** - Зависимости направлены к абстракциям
3. **Single Responsibility** - Каждый класс отвечает за одну задачу
4. **Open/Closed Principle** - Открыт для расширения, закрыт для изменений

## 🏗️ Слои архитектуры

### 1. 📱 Presentation Layer (SwiftUI)
```
Views/
├── LoginView.swift          # Экран авторизации
├── ProfileView.swift        # Профиль пользователя  
├── MarkbookView.swift       # Зачетная книжка
├── GroupInfoView.swift      # Информация о группе
└── MainNavigationView.swift # Основная навигация
```

**Ответственность:**
- Отображение пользовательского интерфейса
- Обработка пользовательского ввода
- Навигация между экранами

### 2. 🌉 Bridge Layer (Objective-C++)
```
Bridge/
├── BSUIRAPIBridge.mm      # Основной API мост
├── HTTPClientBridge.mm    # HTTP клиент мост
├── BSUIRLogBridge.mm      # Логирование мост
└── BSUIRModels.m          # Модели для Swift
```

**Ответственность:**
- Интеграция между Swift и C++
- Преобразование типов данных
- Управление памятью между языками

### 3. 🧠 Business Logic Layer (C++)
```
Core/
├── BSUIROOPDemo.hpp       # Демонстрация ООП принципов
├── ApiService.hpp         # Бизнес-логика API
├── HTTPClient.hpp         # HTTP коммуникации
├── IConfigProvider.hpp    # Конфигурация (DI)
├── SecureTokenStorage.hpp # Безопасное хранение
├── Models.hpp             # Модели данных
└── JSONParser.hpp         # Парсинг JSON
```

**Ответственность:**
- Реализация бизнес-правил
- Демонстрация ООП принципов
- Управление состоянием приложения

## 🧬 ООП Архитектурные решения

### 1. 🔒 Абстракция через интерфейсы

```cpp
// Абстрактный провайдер конфигурации
class IConfigProvider {
public:
    virtual ~IConfigProvider() = default;
    virtual std::string getApiBaseUrl() const = 0;
    virtual bool isDebugMode() const = 0;
    virtual int getRequestTimeout() const = 0;
};

// Конкретная реализация
class ProductionConfigProvider : public IConfigProvider {
    std::string getApiBaseUrl() const override;
    bool isDebugMode() const override { return false; }
    int getRequestTimeout() const override { return 30; }
};
```

### 2. 📦 Инкапсуляция с контролируемым доступом

```cpp
class SecureTokenStorage {
private:
    std::string m_accessToken;    // Приватные данные
    std::string m_refreshToken;
    std::chrono::time_point<std::chrono::steady_clock> m_expiryTime;

    void clearSensitiveData();    // Приватный метод очистки

public:
    // Контролируемый доступ через методы
    bool storeTokens(const std::string& access, const std::string& refresh);
    std::optional<std::string> getAccessToken() const;
    bool isTokenExpired() const noexcept;
};
```

### 3. 🌳 Наследование для специализации

```cpp
// Базовый класс пользователя
class AbstractUser {
protected:
    std::string m_username;
    std::string m_email;
    
public:
    virtual ~AbstractUser() = default;
    virtual std::string getUserType() const = 0;
    virtual bool hasPermission(const std::string& permission) const = 0;
};

// Специализация для студента
class Student : public AbstractUser {
public:
    std::string getUserType() const override { return "Student"; }
    bool hasPermission(const std::string& permission) const override;
    
    // Специфичные методы студента
    std::string getGroup() const;
    std::vector<Grade> getGrades() const;
};
```

### 4. 🎭 Полиморфизм для гибкости

```cpp
// Полиморфное использование
class UserManager {
private:
    std::vector<std::unique_ptr<AbstractUser>> m_users;
    
public:
    void addUser(std::unique_ptr<AbstractUser> user) {
        m_users.push_back(std::move(user));
    }
    
    void processUsers() {
        for (auto& user : m_users) {
            // Полиморфный вызов
            std::cout << "Processing " << user->getUserType() << std::endl;
            user->performUserSpecificAction();
        }
    }
};
```

## 🏭 Паттерны проектирования

### 1. 💉 Dependency Injection
```cpp
class ApiService {
private:
    std::unique_ptr<IConfigProvider> m_configProvider;
    std::unique_ptr<HTTPClient> m_httpClient;
    std::unique_ptr<SecureTokenStorage> m_tokenStorage;

public:
    ApiService(std::unique_ptr<IConfigProvider> config,
               std::unique_ptr<HTTPClient> httpClient,
               std::unique_ptr<SecureTokenStorage> tokenStorage)
        : m_configProvider(std::move(config))
        , m_httpClient(std::move(httpClient))
        , m_tokenStorage(std::move(tokenStorage)) {}
};
```

### 2. 👁️ Observer Pattern
```cpp
class AuthenticationObserver {
public:
    virtual ~AuthenticationObserver() = default;
    virtual void onUserLoggedIn(const AbstractUser* user) = 0;
    virtual void onUserLoggedOut() = 0;
};

class AuthenticationSubject {
private:
    std::vector<AuthenticationObserver*> m_observers;
    
protected:
    void notifyUserLoggedIn(const AbstractUser* user) {
        for (auto* observer : m_observers) {
            observer->onUserLoggedIn(user);
        }
    }
};
```

### 3. ⚡ Strategy Pattern
```cpp
class AuthenticationStrategy {
public:
    virtual ~AuthenticationStrategy() = default;
    virtual bool authenticate(const UserCredentials& creds) = 0;
};

class BSUIRAuthStrategy : public AuthenticationStrategy {
public:
    bool authenticate(const UserCredentials& creds) override;
};

class AuthenticationContext {
private:
    std::unique_ptr<AuthenticationStrategy> m_strategy;
    
public:
    void setStrategy(std::unique_ptr<AuthenticationStrategy> strategy) {
        m_strategy = std::move(strategy);
    }
    
    bool login(const UserCredentials& creds) {
        return m_strategy ? m_strategy->authenticate(creds) : false;
    }
};
```

## 🔄 Потоки данных

### Авторизация пользователя:
```
SwiftUI LoginView 
    → BSUIRAPIBridge 
    → ApiService 
    → HTTPClient 
    → BSUIR API
```

### Получение данных:
```
SwiftUI ProfileView 
    → BSUIRAPIBridge 
    → ApiService (с токеном)
    → HTTPClient 
    → BSUIR API 
    → JSON Response 
    → Models 
    → SwiftUI Update
```

## 📊 Диаграмма компонентов

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   SwiftUI Views │    │ Objective-C++   │    │   C++ Core      │
│                 │    │    Bridges      │    │   Classes       │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • LoginView     │◄──►│ • APIBridge     │◄──►│ • ApiService    │
│ • ProfileView   │    │ • HTTPBridge    │    │ • HTTPClient    │
│ • MarkbookView  │    │ • LogBridge     │    │ • Models        │
│ • GroupView     │    │ • ModelBridge   │    │ • TokenStorage  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🎯 Архитектурные преимущества

### ✅ Достигнутые цели:
1. **Модульность** - Четкое разделение слоев
2. **Тестируемость** - Dependency Injection позволяет мокать зависимости
3. **Расширяемость** - Новые функции легко добавляются
4. **Поддерживаемость** - Понятная структура и документация
5. **Демонстрация ООП** - Все принципы показаны на практике

### 📈 Возможности для развития:
1. **Unit Testing** - Добавление comprehensive test suite
2. **Error Handling** - Более продвинутая обработка ошибок
3. **Caching** - Реализация кеширования данных
4. **Offline Support** - Работа без интернета
5. **Локализация** - Поддержка множественных языков

## 🔧 Технические решения

### Управление памятью:
- **RAII** принцип везде где возможно
- **Smart pointers** вместо raw pointers
- **Move semantics** для оптимизации производительности

### Безопасность:
- Токены хранятся в зашифрованном виде
- Автоматическая очистка чувствительных данных
- Const correctness для предотвращения случайных изменений

### Производительность:
- Ленивая инициализация где применимо
- Эффективное копирование через move semantics
- Минимальное количество аллокаций памяти

---

**🏗️ Эта архитектура демонстрирует зрелое понимание принципов проектирования ПО и ООП!**