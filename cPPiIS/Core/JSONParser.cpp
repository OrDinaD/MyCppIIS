//
//  JSONParser.cpp
//  BSUIRApp Core C++ JSON Parser Implementation
//

#include "JSONParser.hpp"
#include <algorithm>
#include <regex>
#include <iostream>

namespace BSUIR {

std::string JSONParser::trim(const std::string& str) {
    size_t start = str.find_first_not_of(" \t\n\r\"");
    if (start == std::string::npos) return "";
    size_t end = str.find_last_not_of(" \t\n\r\"");
    return str.substr(start, end - start + 1);
}

std::string JSONParser::unescapeString(const std::string& str) {
    std::string result = str;
    std::regex escaped("\\\\\"");
    result = std::regex_replace(result, escaped, "\"");
    std::regex newline("\\\\n");
    result = std::regex_replace(result, newline, "\n");
    return result;
}

std::map<std::string, std::string> JSONParser::parseObject(const std::string& json) {
    std::map<std::string, std::string> result;
    std::string cleaned = json;
    
    // Remove outer braces
    size_t start = cleaned.find('{');
    size_t end = cleaned.find_last_of('}');
    if (start == std::string::npos || end == std::string::npos) return result;
    
    cleaned = cleaned.substr(start + 1, end - start - 1);
    
    // Simple key-value parsing (this is a basic implementation)
    std::regex keyValue("\"([^\"]+)\"\\s*:\\s*([^,}]+)");
    std::sregex_iterator iter(cleaned.begin(), cleaned.end(), keyValue);
    std::sregex_iterator end_iter;
    
    for (; iter != end_iter; ++iter) {
        std::string key = (*iter)[1].str();
        std::string value = trim((*iter)[2].str());
        result[key] = unescapeString(value);
    }
    
    return result;
}

std::vector<std::string> JSONParser::parseArray(const std::string& json) {
    std::vector<std::string> result;
    std::string cleaned = json;
    
    // Remove outer brackets
    size_t start = cleaned.find('[');
    size_t end = cleaned.find_last_of(']');
    if (start == std::string::npos || end == std::string::npos) return result;
    
    cleaned = cleaned.substr(start + 1, end - start - 1);
    
    // Simple array parsing
    size_t pos = 0;
    size_t comma;
    while ((comma = cleaned.find(',', pos)) != std::string::npos) {
        result.push_back(trim(cleaned.substr(pos, comma - pos)));
        pos = comma + 1;
    }
    result.push_back(trim(cleaned.substr(pos)));
    
    return result;
}

std::optional<int> JSONParser::parseOptionalInt(const std::string& value) {
    if (value == "null" || value.empty()) return std::nullopt;
    try {
        return std::stoi(value);
    } catch (...) {
        return std::nullopt;
    }
}

std::optional<double> JSONParser::parseOptionalDouble(const std::string& value) {
    if (value == "null" || value.empty()) return std::nullopt;
    try {
        return std::stod(value);
    } catch (...) {
        return std::nullopt;
    }
}

std::optional<LoginResponse> JSONParser::parseLoginResponse(const std::string& json) {
    std::cout << "🔍 JSONParser: Parsing login response:" << std::endl;
    std::cout << "🔍 Raw JSON: " << json << std::endl;
    
    auto obj = parseObject(json);
    if (obj.empty()) {
        std::cout << "❌ JSONParser: Failed to parse JSON object" << std::endl;
        return std::nullopt;
    }
    
    std::cout << "🔍 Parsed object keys:" << std::endl;
    for (const auto& pair : obj) {
        std::cout << "🔍 Key: " << pair.first << ", Value: " << pair.second << std::endl;
    }
    
    LoginResponse response;
    
    try {
        // BSUIR API returns user info directly, not OAuth tokens
        // We'll simulate a session-based authentication
        response.accessToken = "session_based_auth"; // Placeholder since API uses session cookies
        response.refreshToken = "";
        response.tokenType = "Session";
        response.expiresIn = 3600; // Default session time
        
        // Parse user data from the direct response
        response.studentNumber = obj["username"];
        
        // Parse FIO (Full name in Russian format: "Фамилия Имя Отчество")
        std::string fio = obj["fio"];
        size_t firstSpace = fio.find(' ');
        size_t secondSpace = fio.find(' ', firstSpace + 1);
        
        if (firstSpace != std::string::npos) {
            response.lastName = fio.substr(0, firstSpace);
            if (secondSpace != std::string::npos) {
                response.firstName = fio.substr(firstSpace + 1, secondSpace - firstSpace - 1);
                response.middleName = fio.substr(secondSpace + 1);
            } else {
                response.firstName = fio.substr(firstSpace + 1);
                response.middleName = "";
            }
        } else {
            response.lastName = fio;
            response.firstName = "";
            response.middleName = "";
        }
        
        // Set a default userId (API doesn't return numeric ID in this response)
        response.userId = 1; // We'll use 1 as default since we don't have ID in response
        
        std::cout << "✅ JSONParser: Successfully parsed login response" << std::endl;
        std::cout << "👤 Student: " << response.firstName << " " << response.lastName << std::endl;
        std::cout << "🎫 Student Number: " << response.studentNumber << std::endl;
        return response;
    } catch (const std::exception& e) {
        std::cout << "❌ JSONParser: Exception parsing login response: " << e.what() << std::endl;
        return std::nullopt;
    } catch (...) {
        std::cout << "❌ JSONParser: Unknown error parsing login response" << std::endl;
        return std::nullopt;
    }
}

std::optional<PersonalInfo> JSONParser::parsePersonalInfo(const std::string& json) {
    auto obj = parseObject(json);
    if (obj.empty()) return std::nullopt;
    
    PersonalInfo info;
    
    try {
        info.id = std::stoi(obj["id"]);
        info.studentNumber = obj["studentNumber"];
        info.firstName = obj["firstName"];
        info.lastName = obj["lastName"];
        info.middleName = obj["middleName"];
        info.firstNameBel = obj["firstNameBel"];
        info.lastNameBel = obj["lastNameBel"];
        info.middleNameBel = obj["middleNameBel"];
        info.birthDate = obj["birthDate"];
        info.course = std::stoi(obj["course"]);
        info.faculty = obj["faculty"];
        info.speciality = obj["speciality"];
        info.group = obj["group"];
        info.email = obj["email"];
        info.phone = obj["phone"];
        
        return info;
    } catch (...) {
        return std::nullopt;
    }
}

std::optional<Markbook> JSONParser::parseMarkbook(const std::string& json) {
    auto obj = parseObject(json);
    if (obj.empty()) return std::nullopt;
    
    Markbook markbook;
    
    try {
        markbook.studentNumber = obj["studentNumber"];
        markbook.overallGPA = std::stod(obj["overallGPA"]);
        
        // Note: Full array parsing would be more complex
        // This is a simplified version
        
        return markbook;
    } catch (...) {
        return std::nullopt;
    }
}

std::optional<GroupInfo> JSONParser::parseGroupInfo(const std::string& json) {
    auto obj = parseObject(json);
    if (obj.empty()) return std::nullopt;
    
    GroupInfo info;
    
    try {
        info.number = obj["number"];
        info.faculty = obj["faculty"];
        info.course = std::stoi(obj["course"]);
        
        // Simplified parsing - in real implementation would parse nested objects
        info.curator.fullName = obj["curatorName"];
        info.curator.phone = obj["curatorPhone"];
        info.curator.email = obj["curatorEmail"];
        
        return info;
    } catch (...) {
        return std::nullopt;
    }
}

ApiError JSONParser::parseError(const std::string& json, int httpCode) {
    std::cout << "🚨 JSONParser: Parsing error response" << std::endl;
    std::cout << "🚨 HTTP Code: " << httpCode << std::endl;
    std::cout << "🚨 Raw response: " << json << std::endl;
    
    auto obj = parseObject(json);
    
    ApiError error;
    error.code = httpCode;
    
    // Try different possible error message fields in JSON
    if (obj.count("message")) {
        error.message = obj["message"];
        std::cout << "📄 Found error message: " << error.message << std::endl;
    } else if (obj.count("error_description")) {
        error.message = obj["error_description"];
        std::cout << "📄 Found error_description: " << error.message << std::endl;
    } else if (obj.count("error") && obj.count("path")) {
        // BSUIR API specific format: {"timestamp":..,"status":401,"error":"Unauthorized","path":"/api/v1/auth/login"}
        std::string errorType = obj["error"];
        std::string path = obj["path"];
        std::string status = obj.count("status") ? obj["status"] : std::to_string(httpCode);
        
        // Create user-friendly message based on error type and path
        if (errorType == "Unauthorized" && path.find("/auth/login") != std::string::npos) {
            error.message = "Неверные учетные данные (номер билета или пароль)";
        } else {
            error.message = "Ошибка " + status + ": " + errorType + " (" + path + ")";
        }
        std::cout << "📄 BSUIR API format error: " << error.message << std::endl;
    } else if (obj.count("error")) {
        error.message = obj["error"];
        std::cout << "📄 Found error field: " << error.message << std::endl;
    } else if (obj.count("status")) {
        error.message = obj["status"];
        std::cout << "📄 Found status field: " << error.message << std::endl;
    } else {
        // Fallback error messages
        if (httpCode == 400) {
            error.message = "Неверный формат запроса";
        } else if (httpCode == 401) {
            error.message = "Неверные учетные данные";
        } else if (httpCode == 403) {
            error.message = "Доступ запрещен";
        } else if (httpCode == 404) {
            error.message = "API не найден";
        } else if (httpCode == 500) {
            error.message = "Внутренняя ошибка сервера";
        } else {
            error.message = "HTTP " + std::to_string(httpCode) + " ошибка";
        }
        std::cout << "📄 Using fallback error message: " << error.message << std::endl;
    }
    
    // Include additional details if available
    std::string details = "";
    if (obj.count("details")) {
        details = obj["details"];
    } else if (obj.count("timestamp") || obj.count("path")) {
        // BSUIR API format - include timestamp and path info
        std::ostringstream detailsStream;
        if (obj.count("timestamp")) {
            detailsStream << "Время: " << obj["timestamp"];
        }
        if (obj.count("path")) {
            if (!detailsStream.str().empty()) detailsStream << ", ";
            detailsStream << "Путь: " << obj["path"];
        }
        if (obj.count("status")) {
            if (!detailsStream.str().empty()) detailsStream << ", ";
            detailsStream << "Статус: " << obj["status"];
        }
        details = detailsStream.str();
    } else {
        details = json; // Include full response as details
    }
    
    error.details = details;
    
    std::cout << "🚨 Final parsed error: Code=" << error.code 
              << ", Message=" << error.message 
              << ", Details=" << error.details << std::endl;
    
    return error;
}

std::string BSUIR::JSONParser::createLoginRequest(const std::string& login, 
                                         const std::string& password, 
                                         bool rememberMe) {
    // Correct BSUIR IIS API login request format - uses "username" field
    std::ostringstream oss;
    oss << "{"
        << "\"username\":\"" << login << "\","
        << "\"password\":\"" << password << "\"";
    
    // Only add rememberMe if it's true (API might not need this field)
    if (rememberMe) {
        oss << ",\"rememberMe\":true";
    }
    
    oss << "}";
    
    std::string requestBody = oss.str();
    std::cout << "🔑 JSONParser: Creating corrected login request:" << std::endl;
    std::cout << "🔑 Request body: " << requestBody << std::endl;
    
    return requestBody;
}

} // namespace BSUIR