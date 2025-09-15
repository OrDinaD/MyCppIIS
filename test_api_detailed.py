#!/usr/bin/env python3
"""
Детальный тестовый скрипт для проверки API БГУИР с различными форматами данных
"""

import requests
import json

API_BASE = "https://iis.bsuir.by/api/v1"

def test_login_variant(username, password, variant_name, data_format):
    """Тестирует логин с различными форматами данных"""
    
    url = f"{API_BASE}/auth/login"
    
    headers = {
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15"
    }
    
    print(f"\n🔐 Вариант {variant_name}: {username}")
    print(f"📤 URL: {url}")
    print(f"📤 Данные: {json.dumps(data_format, indent=2)}")
    
    try:
        response = requests.post(url, json=data_format, headers=headers, timeout=30)
        
        print(f"📥 Статус: {response.status_code}")
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
            print(f"❌ Ошибка аутентификации: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"💥 Ошибка запроса: {e}")
        return None

def test_markbook(token):
    """Тестирует получение зачетной книжки"""
    
    url = f"{API_BASE}/markbook"
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    print(f"\n📚 Получаем зачетную книжку")
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
            
        return response.json() if response.status_code == 200 else None
            
    except Exception as e:
        print(f"💥 Ошибка запроса: {e}")
        return None

def test_group_info(token):
    """Тестирует получение информации о группе"""
    
    url = f"{API_BASE}/student-group"
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    print(f"\n👥 Получаем информацию о группе")
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
            
        return response.json() if response.status_code == 200 else None
            
    except Exception as e:
        print(f"💥 Ошибка запроса: {e}")
        return None

if __name__ == "__main__":
    print("🚀 Детальное тестирование API БГУИР")
    print("="*60)
    
    username = "42850012"
    password = "Bsuirinyouv.12_"
    
    # Пробуем разные варианты структуры данных
    variants = [
        ("Стандартный", {
            "username": username,
            "password": password,
            "rememberMe": True
        }),
        ("Логин как login", {
            "login": username,
            "password": password,
            "rememberMe": True
        }),
        ("Логин как studentId", {
            "studentId": username,
            "password": password,
            "rememberMe": True
        }),
        ("Логин как recordBookNumber", {
            "recordBookNumber": username,
            "password": password,
            "rememberMe": True
        }),
        ("Без rememberMe", {
            "username": username,
            "password": password
        }),
        ("С email форматом", {
            "email": username,
            "password": password
        })
    ]
    
    successful_login = None
    
    for variant_name, data_format in variants:
        result = test_login_variant(username, password, variant_name, data_format)
        if result and "access_token" in result:
            successful_login = result
            print(f"\n🎉 Успешный логин через вариант: {variant_name}")
            break
        print("-" * 40)
    
    if successful_login:
        token = successful_login["access_token"]
        print(f"\n🎟️ Получен токен: {token[:20]}...")
        
        # Тестируем различные API эндпоинты
        print("\n" + "="*60)
        print("📊 ТЕСТИРОВАНИЕ API ENDPOINTS")
        print("="*60)
        
        # Личная информация
        print(f"\n👤 Получаем личную информацию")
        try:
            response = requests.get(f"{API_BASE}/personal-information", 
                                  headers={"Authorization": f"Bearer {token}"}, 
                                  timeout=30)
            print(f"Статус: {response.status_code}")
            if response.status_code == 200:
                print(json.dumps(response.json(), indent=2, ensure_ascii=False))
        except Exception as e:
            print(f"Ошибка: {e}")
        
        # Зачетная книжка
        test_markbook(token)
        
        # Информация о группе
        test_group_info(token)
        
    else:
        print("\n💔 Ни один из вариантов логина не сработал")
        print("🔍 Возможные причины:")
        print("  - Неверные учетные данные")
        print("  - Изменился формат API")
        print("  - Требуется дополнительная авторизация")