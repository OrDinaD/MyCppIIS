<img src="logoIIS.png" align="left" width="120" style="margin-right: 20px; border-radius: 15px;">

# cPPiIS

**C++ Powered iOS Information System** — современное iOS приложение с нативной C++ бизнес-логикой для работы с информационной системой.

🎓 **Курсовая работа по ООП** — архитектура построена на принципах объектно-ориентированного программирования с использованием современных паттернов проектирования и безопасных практик разработки.

📚 [**Документация по ООП**](docs/CPP_OOP_Documentation.md) • [**Архитектура**](docs/ARCHITECTURE.md)

<br clear="left"/>

## ⚡ Технологии

![iOS](https://img.shields.io/badge/iOS-18.6-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-16-brightgreen.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![C++](https://img.shields.io/badge/C++-17/20-red.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📁 Структура проекта

```
cPPiIS/
├── Core/                    # C++ бизнес-логика
│   ├── ApiService.hpp      # Главный API сервис
│   ├── HTTPClient.hpp      # HTTP клиент
│   ├── SecureTokenStorage.hpp # Безопасное хранение
│   └── Models.hpp          # Модели данных
├── Bridge/                 # Objective-C++ мосты
│   ├── BSUIRAPIBridge.mm   # Swift ↔ C++ мост
│   └── HTTPClientBridge.mm # HTTP мост
└── Views/                  # SwiftUI интерфейс
    ├── LoginView.swift     # Аутентификация
    ├── ProfileView.swift   # Профиль пользователя
    └── MarkbookView.swift  # Зачетная книжка
```

## 🏗️ Архитектурные особенности

**Swift + C++ интеграция** — SwiftUI интерфейс с нативной C++ бизнес-логикой через Objective-C++ мосты.

**Современный C++** — использование умных указателей, RAII, move semantics и безопасного управления памятью.

**Паттерны проектирования** — Singleton для конфигурации, Factory для создания объектов, Observer для уведомлений.

**Безопасность** — токены хранятся в iOS Keychain, все HTTP запросы защищены SSL pinning.

## 🧩 ООП принципы в проекте

**Инкапсуляция** — скрытие внутренней реализации через PIMPL идиому и приватные методы.

**Наследование** — иерархии классов для различных типов хранилищ и парсеров данных.

**Полиморфизм** — виртуальные функции для различных стратегий сетевых запросов.

**Абстракция** — интерфейсы для работы с конфигурацией и хранением данных.

## 🚀 Быстрый старт

1. Откройте `cPPiIS.xcodeproj` в Xcode 16+
2. Выберите симулятор iPhone (iOS 18.6+)
3. Нажмите `⌘ + R` для запуска

---

*🎓 Курсовая работа по дисциплине "Объектно-ориентированное программирование" — демонстрация современных ООП практик в мобильной разработке с акцентом на архитектуру и качество кода.*
