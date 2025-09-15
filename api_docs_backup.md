# BSUIR IIS API Documentation

## Обзор

Это документация для API системы ИИС БГУИР (Информационно-образовательная система Белорусского государственного университета информатики и радиоэлектроники). API предоставляет доступ к личной информации студентов, академическим данным и различным сервисам университета.

**Base URL**: `https://iis.bsuir.by/api/v1`

## Аутентификация

### Bearer Token Authentication

API использует Bearer token аутентификацию. После успешного входа в систему, все последующие запросы должны включать JWT токен в заголовке Authorization.

```http
Authorization: Bearer <your_jwt_token>
```

### Эндпоинт входа

**POST** `/auth/login`

Аутентификация пользователя в системе.

#### Параметры запроса

```json
{
  "login": "string",     // Номер студенческого билета или логин
  "password": "string",  // Пароль пользователя
  "rememberMe": "boolean" // Запомнить устройство (опционально)
}
```

#### Пример запроса

```bash
curl -X POST "https://iis.bsuir.by/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "login": "42850012",
    "password": "your_password",
    "rememberMe": true
  }'
```

#### Пример ответа

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": 12345,
    "studentNumber": "42850012",
    "firstName": "Владислав",
    "lastName": "Василевский",
    "middleName": "Валерьевич"
  }
}
```

#### Коды ошибок

- `400 Bad Request` - Неверные параметры запроса
- `401 Unauthorized` - Неверные учетные данные
- `403 Forbidden` - Доступ запрещен
- `500 Internal Server Error` - Внутренняя ошибка сервера

---

## Профиль и личная информация

### Получить личную информацию

**GET** `/personal-information`

Возвращает основную личную информацию пользователя.

#### Заголовки

```http
Authorization: Bearer <token>
```

#### Пример запроса

```bash
curl -X GET "https://iis.bsuir.by/api/v1/personal-information" \
  -H "Authorization: Bearer <your_token>"
```

#### Пример ответа

```json
{
  "id": 12345,
  "studentNumber": "42850012",
  "firstName": "Владислав",
  "lastName": "Василевский",
  "middleName": "Валерьевич",
  "firstNameBel": "Уладзіслаў",
  "lastNameBel": "Васілеўскі",
  "middleNameBel": "Валер'евіч",
  "birthDate": "2007-06-14",
  "course": 2,
  "faculty": "ФИТУ",
  "speciality": "СУИ (АСОИ)",
  "group": "420603",
  "email": "vlad.vasilevskiy.07@gmail.com",
  "phone": "+375299605390"
}
```

### Получить дополнительные данные

**GET** `/personal-information/illiquid-data`

Возвращает дополнительную информацию профиля.

#### Заголовки

```http
Authorization: Bearer <token>
```

#### Пример ответа

```json
{
  "profilePhoto": "https://storage.googleapis.com/students-bsuir.appspot.com/public_ids/...",
  "preferences": {
    "language": "ru",
    "theme": "light"
  },
  "accessPermissions": {
    "profileVisible": true,
    "ratingVisible": true,
    "jobSearchVisible": false
  }
}
```

### Получить CV профиль

**GET** `/profiles/personal-cv`

Возвращает профиль резюме пользователя.

#### Заголовки

```http
Authorization: Bearer <token>
```

#### Пример ответа

```json
{
  "skills": [
    "Swift",
    "баттл кап в доте",
    "Играю в циву"
  ],
  "links": [
    {
      "name": "GitHub",
      "url": "https://github.com/OrDinaD",
      "type": "github"
    },
    {
      "name": "LinkedIn",
      "url": "https://www.linkedin.com/in/владислав-в-493b0b172/",
      "type": "linkedin"
    }
  ],
  "summary": "Студент 2 курса факультета ФИТУ",
  "experience": [],
  "education": [
    {
      "institution": "БГУИР",
      "faculty": "ФИТУ",
      "speciality": "СУИ (АСОИ)",
      "startYear": 2023,
      "expectedGraduation": 2027
    }
  ]
}
```

### Поиск навыков

**GET** `/skill`

Поиск навыков для автодополнения в профиле.

#### Параметры запроса

- `name` (string, optional) - Название навыка для поиска

#### Пример запроса

```bash
curl -X GET "https://iis.bsuir.by/api/v1/skill?name=Java" \
  -H "Authorization: Bearer <your_token>"
```

#### Пример ответа

```json
{
  "skills": [
    "Java",
    "JavaScript",
    "Java Spring",
    "Java EE"
  ]
}
```

---

## Академическая информация

### Получить зачетную книжку

**GET** `/markbook`

Возвращает данные зачетной книжки студента.

#### Заголовки

```http
Authorization: Bearer <token>
```

#### Пример ответа

```json
{
  "studentNumber": "42850012",
  "overallGPA": 9.42,
  "semesters": [
    {
      "number": 1,
      "gpa": 9.85,
      "subjects": [
        {
          "name": "Математика",
          "hours": 144.0,
          "credits": 4,
          "controlForm": "Экзамен",
          "grade": 10,
          "retakes": 0,
          "averageGrade": 8.5,
          "retakeChance": 0.0,
          "isOnline": false
        }
      ]
    },
    {
      "number": 3,
      "gpa": 0,
      "subjects": [
        {
          "name": "АПЭЦ",
          "hours": 108.0,
          "credits": 3,
          "controlForm": "Зачет",
          "grade": null,
          "retakes": 0,
          "averageGrade": null,
          "retakeChance": 0.0,
          "isOnline": false
        },
        {
          "name": "ООП",
          "hours": 216.0,
          "credits": 6,
          "controlForm": "Экзамен",
          "grade": null,
          "retakes": 0,
          "averageGrade": 7.37,
          "retakeChance": 0.8,
          "isOnline": true
        }
      ]
    }
  ]
}
```

### Получить информацию о группе

**GET** `/student-groups/user-group-info`

Возвращает информацию о группе студента.

#### Заголовки

```http
Authorization: Bearer <token>
```

#### Пример ответа

```json
{
  "group": {
    "number": "420603",
    "faculty": "ФИТУ",
    "course": 2,
    "curator": {
      "fullName": "Трофимович Алексей Фёдорович",
      "phone": "+375172938997",
      "email": "trofimaf@bsuir.by",
      "profileUrl": "/employees/a-trofimovich"
    }
  },
  "students": [
    {
      "number": 1,
      "fullName": "Борутенко Богдан Владимирович"
    },
    {
      "number": 2,
      "fullName": "Бугай Елизавета Андреевна"
    },
    {
      "number": 3,
      "fullName": "Василевский Владислав Валерьевич"
    }
  ]
}
```

---

## Учебные сервисы

### Получить ведомостички

**GET** `/mark-sheet`

Возвращает список заказанных ведомостичек.

#### Заголовки

```http
Authorization: Bearer <token>
```

#### Пример ответа

```json
{
  "markSheets": [
    {
      "id": 1001,
      "orderDate": "2024-09-01",
      "status": "готова",
      "subject": "Математика",
      "semester": 1,
      "type": "экзаменационная"
    }
  ],
  "canOrder": true,
  "paymentInfo": {
    "system": "ЕРИП",
    "path": "Образование и развитие - Высшее образование - Минск - БГУИР - Академ. задолженность и проч."
  }
}
```

### Получить справки

**GET** `/certificate`

Возвращает список заказанных справок.

#### Заголовки

```http
Authorization: Bearer <token>
```

#### Пример ответа

```json
{
  "certificates": [
    {
      "number": "5187",
      "orderDate": "25.08.2025",
      "purpose": "по месту работы родителей (ТЦСОН Островца)",
      "status": "напечатана",
      "rejectReason": null
    },
    {
      "number": "4631",
      "orderDate": "19.05.2025",
      "purpose": "в Управление по труду и социальной защиты г. Островца",
      "status": "отклонена",
      "rejectReason": "Данные справки выдаёт соц.педагог (324-4)"
    }
  ],
  "canOrder": true
}
```

### Получить историю заявок LMS

**GET** `/lms/application-history`

Возвращает историю заявок на изучение дисциплин с помощью ДОТ.

#### Заголовки

```http
Authorization: Bearer <token>
```

#### Пример ответа

```json
{
  "applications": [],
  "hasApplications": false,
  "currentSemester": 3
}
```

---

## Коды статусов HTTP

- **200 OK** - Запрос выполнен успешно
- **400 Bad Request** - Неверные параметры запроса
- **401 Unauthorized** - Требуется аутентификация
- **403 Forbidden** - Доступ запрещен
- **404 Not Found** - Ресурс не найден
- **500 Internal Server Error** - Внутренняя ошибка сервера

---

## Модели данных

### User

```json
{
  "id": "integer",
  "studentNumber": "string",
  "firstName": "string",
  "lastName": "string",
  "middleName": "string",
  "firstNameBel": "string",
  "lastNameBel": "string",
  "middleNameBel": "string",
  "birthDate": "string (YYYY-MM-DD)",
  "course": "integer",
  "faculty": "string",
  "speciality": "string",
  "group": "string",
  "email": "string",
  "phone": "string"
}
```

### Subject

```json
{
  "name": "string",
  "hours": "number",
  "credits": "integer",
  "controlForm": "string",
  "grade": "integer | null",
  "retakes": "integer",
  "averageGrade": "number | null",
  "retakeChance": "number",
  "isOnline": "boolean"
}
```

### Semester

```json
{
  "number": "integer",
  "gpa": "number",
  "subjects": "Subject[]"
}
```

---

## Примеры интеграции для iOS

### Swift (URLSession)

```swift
import Foundation

class BSUIRAPIClient {
    private let baseURL = "https://iis.bsuir.by/api/v1"
    private var authToken: String?
    
    func login(studentNumber: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginData = LoginRequest(login: studentNumber, password: password, rememberMe: true)
        
        do {
            request.httpBody = try JSONEncoder().encode(loginData)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                self.authToken = loginResponse.accessToken
                completion(.success(loginResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getPersonalInfo(completion: @escaping (Result<PersonalInfo, Error>) -> Void) {
        guard let token = authToken,
              let url = URL(string: "\(baseURL)/personal-information") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let personalInfo = try JSONDecoder().decode(PersonalInfo.self, from: data)
                completion(.success(personalInfo))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Models

struct LoginRequest: Codable {
    let login: String
    let password: String
    let rememberMe: Bool
}

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case user
    }
}

struct PersonalInfo: Codable {
    let id: Int
    let studentNumber: String
    let firstName: String
    let lastName: String
    let middleName: String
    let birthDate: String
    let course: Int
    let faculty: String
    let speciality: String
    let group: String
    let email: String
    let phone: String
}
```

### Использование

```swift
let apiClient = BSUIRAPIClient()

// Вход в систему
apiClient.login(studentNumber: "42850012", password: "your_password") { result in
    switch result {
    case .success(let loginResponse):
        print("Успешный вход: \(loginResponse.user.firstName)")
        
        // Получение личной информации
        apiClient.getPersonalInfo { result in
            switch result {
            case .success(let personalInfo):
                print("Группа: \(personalInfo.group)")
            case .failure(let error):
                print("Ошибка: \(error)")
            }
        }
        
    case .failure(let error):
        print("Ошибка входа: \(error)")
    }
}
```

---

## Безопасность

1. **Всегда используйте HTTPS** для всех запросов к API
2. **Храните токены безопасно** - используйте Keychain в iOS
3. **Обновляйте токены** - следите за временем истечения токена
4. **Валидируйте входные данные** перед отправкой запросов
5. **Обрабатывайте ошибки** - всегда проверяйте коды статусов HTTP

---

## Ограничения

- API требует аутентификации для всех запросов кроме логина
- Некоторые эндпоинты могут быть недоступны в зависимости от роли пользователя
- Токены имеют ограниченное время жизни
- Есть ограничения на частоту запросов (rate limiting)

---

*Документация создана на основе анализа реального API сайта iis.bsuir.by*