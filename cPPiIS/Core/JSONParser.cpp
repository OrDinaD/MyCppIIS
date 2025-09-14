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
        response.accessToken = obj["access_token"];
        response.refreshToken = obj["refresh_token"];
        response.tokenType = obj["token_type"];
        response.expiresIn = std::stoi(obj["expires_in"]);
        
        // Parse nested user object (simplified)
        response.userId = std::stoi(obj["id"]);  // Assuming user data is flattened
        response.studentNumber = obj["studentNumber"];
        response.firstName = obj["firstName"];
        response.lastName = obj["lastName"];
        response.middleName = obj["middleName"];
        
        std::cout << "✅ JSONParser: Successfully parsed login response" << std::endl;
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
    auto obj = parseObject(json);
    
    ApiError error;
    error.code = httpCode;
    error.message = obj.count("message") ? obj["message"] : "Unknown error";
    error.details = obj.count("details") ? obj["details"] : json;
    
    return error;
}

std::string JSONParser::createLoginRequest(const std::string& login, 
                                         const std::string& password, 
                                         bool rememberMe) {
    // Format 2: Standard BSUIR IIS API login request format
    std::ostringstream oss;
    oss << "{"
        << "\"login\":\"" << login << "\","
        << "\"password\":\"" << password << "\","
        << "\"rememberMe\":" << (rememberMe ? "true" : "false")
        << "}";
    
    std::string requestBody = oss.str();
    std::cout << "🔑 JSONParser: Creating Format 2 login request:" << std::endl;
    std::cout << "🔑 Request body: " << requestBody << std::endl;
    
    return requestBody;
}

} // namespace BSUIR