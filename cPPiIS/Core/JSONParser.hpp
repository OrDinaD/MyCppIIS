//
//  JSONParser.hpp
//  BSUIRApp Core C++ JSON Parser
//
//  Simple JSON parser for API responses
//

#ifndef JSONParser_hpp
#define JSONParser_hpp

#include "Models.hpp"
#include <string>
#include <map>
#include <vector>
#include <sstream>
#include <optional>

namespace BSUIR {

class JSONParser {
private:
    static std::string trim(const std::string& str);
    static std::string unescapeString(const std::string& str);
    static std::map<std::string, std::string> parseObject(const std::string& json);
    static std::vector<std::string> parseArray(const std::string& json);
    static std::optional<int> parseOptionalInt(const std::string& value);
    static std::optional<double> parseOptionalDouble(const std::string& value);
    
public:
    // Parse login response
    static std::optional<LoginResponse> parseLoginResponse(const std::string& json);
    
    // Parse personal information
    static std::optional<PersonalInfo> parsePersonalInfo(const std::string& json);
    
    // Parse markbook data
    static std::optional<Markbook> parseMarkbook(const std::string& json);
    
    // Parse group information
    static std::optional<GroupInfo> parseGroupInfo(const std::string& json);
    
    // Parse generic API error
    static ApiError parseError(const std::string& json, int httpCode = 0);
    
    // Utility methods
    static std::string createLoginRequest(const std::string& login, 
                                        const std::string& password, 
                                        bool rememberMe = true);
};

} // namespace BSUIR

#endif /* JSONParser_hpp */