#!/usr/bin/env python3
"""
Тестовый скрипт для проверки API БГУИР
"""

import requests
import json

API_BASE = "https://iis.bsuir.by/api/v1"

def test_login(username, password):
    """Тестирует логин с заданными учетными данными"""
    
    url = f"{API_BASE}/auth/login"
    
    data = {
        "username": username,
        "password": password,
        "rememberMe": True
    }
    
    headers = {
        "Content-Type": "application/json"
    }
    
    print(f"🔐 Тестируем логин для пользователя: {username}")
    print(f"📤 URL: {url}")
    print(f"📤 Данные: {json.dumps(data, indent=2)}")
    
    try:
        response = requests.post(url, json=data, headers=headers, timeout=30)
        
        print(f"📥 Статус: {response.status_code}")
        print(f"📥 Заголовки ответа:")
        for key, value in response.headers.items():
            print(f"  {key}: {value}")
        
        print(f"📥 Тело ответа:")
        try:
            response_json = response.json()
            print(json.dumps(response_json, indent=2, ensure_ascii=False))
        except:
            print(response.text)
            
        if response.status_code == 200:
            print("✅ Успешная аутентификация!")
            return response.json()
        else:
            print("❌ Ошибка аутентификации")
            return None
            
    except Exception as e:
        print(f"💥 Ошибка запроса: {e}")
        return None

def test_personal_info(token):
    """Тестирует получение личной информации"""
    
    url = f"{API_BASE}/personal-information"
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    print(f"\n👤 Получаем личную информацию")
    print(f"📤 URL: {url}")
    
    try:
        response = requests.get(url, headers=headers, timeout=30)
        
        print(f"📥 Статус: {response.status_code}")
        print(f"📥 Тело ответа:")
        try:
            response_json = response.json()
            print(json.dumps(response_json, indent=2, ensure_ascii=False))
        except:
            print(response.text)
            
        if response.status_code == 200:
            print("✅ Данные получены!")
            return response.json()
        else:
            print("❌ Ошибка получения данных")
            return None
            
    except Exception as e:
        print(f"💥 Ошибка запроса: {e}")
        return None

if __name__ == "__main__":
    # Тестируем с реальными учетными данными
    print("🚀 Начинаем тестирование API БГУИР")
    print("="*50)
    
    # Реальные учетные данные пользователя
    username = "42850012"
    password = "Bsuirinyouv.12_"
    
    # Тест 1: Логин
    login_result = test_login(username, password)
    
    if login_result and "access_token" in login_result:
        token = login_result["access_token"]
        print(f"\n🎟️ Получен токен: {token[:20]}...")
        
        # Тест 2: Личная информация
        personal_info = test_personal_info(token)
    else:
        print("\n❓ Возможно, нужно попробовать другие учетные данные")
        print("💡 Проверьте актуальные данные для входа в систему БГУИР")