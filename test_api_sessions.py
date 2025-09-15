#!/usr/bin/env python3
"""
Тестирование API БГУИР с использованием сессионных cookies
"""

import requests
import json

API_BASE = "https://iis.bsuir.by/api/v1"

def login_and_test_all():
    """Логинимся и тестируем все endpoints с сессией"""
    
    # Создаем сессию для сохранения cookies
    session = requests.Session()
    
    # Устанавливаем заголовки
    session.headers.update({
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15"
    })
    
    print("🚀 Тестирование API БГУИР с сессиями")
    print("="*60)
    
    # === АУТЕНТИФИКАЦИЯ ===
    print("🔐 Выполняем аутентификацию...")
    login_data = {
        "username": "42850012",
        "password": "Bsuirinyouv.12_"
    }
    
    login_response = session.post(f"{API_BASE}/auth/login", json=login_data)
    
    print(f"📥 Статус логина: {login_response.status_code}")
    if login_response.status_code == 200:
        user_info = login_response.json()
        print("✅ Успешная аутентификация!")
        print(f"👤 Пользователь: {user_info['fio']}")
        print(f"👥 Группа: {user_info['group']}")
        print(f"📧 Email: {user_info['email']}")
        
        # Проверяем cookies
        print(f"\n🍪 Получены cookies: {len(session.cookies)} штук")
        for cookie in session.cookies:
            print(f"  - {cookie.name}: {cookie.value[:20]}...")
    else:
        print("❌ Ошибка аутентификации!")
        print(login_response.text)
        return
    
    print("\n" + "="*60)
    print("📊 ТЕСТИРОВАНИЕ API ENDPOINTS")
    print("="*60)
    
    # === ЗАЧЕТНАЯ КНИЖКА ===
    print("\n📚 Получаем зачетную книжку...")
    markbook_response = session.get(f"{API_BASE}/markbook")
    
    print(f"📥 Статус: {markbook_response.status_code}")
    if markbook_response.status_code == 200:
        markbook_data = markbook_response.json()
        print("✅ Зачетная книжка получена!")
        print(f"📖 Количество записей: {len(markbook_data) if isinstance(markbook_data, list) else 'неизвестно'}")
        
        # Показываем первые несколько записей
        if isinstance(markbook_data, list) and len(markbook_data) > 0:
            print("📋 Первые записи:")
            for i, record in enumerate(markbook_data[:3]):
                print(f"  {i+1}. {record.get('subject', 'N/A')} - {record.get('mark', 'N/A')}")
        else:
            print(f"📋 Данные: {json.dumps(markbook_data, indent=2, ensure_ascii=False)[:500]}...")
    else:
        print("❌ Ошибка получения зачетной книжки")
        print(markbook_response.text[:300])
    
    # === ЛИЧНАЯ ИНФОРМАЦИЯ ===
    print("\n👤 Получаем личную информацию...")
    personal_response = session.get(f"{API_BASE}/personal-information")
    
    print(f"📥 Статус: {personal_response.status_code}")
    if personal_response.status_code == 200:
        personal_data = personal_response.json()
        print("✅ Личная информация получена!")
        print(f"📋 Данные: {json.dumps(personal_data, indent=2, ensure_ascii=False)[:500]}...")
    else:
        print("❌ Ошибка получения личной информации")
        print(personal_response.text[:300])
    
    # === ИНФОРМАЦИЯ О ГРУППЕ ===
    print("\n👥 Получаем информацию о группе...")
    group_response = session.get(f"{API_BASE}/student-group")
    
    print(f"📥 Статус: {group_response.status_code}")
    if group_response.status_code == 200:
        group_data = group_response.json()
        print("✅ Информация о группе получена!")
        if isinstance(group_data, dict):
            print(f"👥 Группа: {group_data.get('name', 'N/A')}")
            print(f"🏫 Факультет: {group_data.get('faculty', 'N/A')}")
            students = group_data.get('students', [])
            print(f"👨‍🎓 Студентов в группе: {len(students) if isinstance(students, list) else 'неизвестно'}")
        else:
            print(f"📋 Данные: {json.dumps(group_data, indent=2, ensure_ascii=False)[:500]}...")
    else:
        print("❌ Ошибка получения информации о группе")
        print(group_response.text[:300])
    
    # === РАСПИСАНИЕ ===
    print("\n📅 Получаем расписание...")
    schedule_response = session.get(f"{API_BASE}/schedule")
    
    print(f"📥 Статус: {schedule_response.status_code}")
    if schedule_response.status_code == 200:
        schedule_data = schedule_response.json()
        print("✅ Расписание получено!")
        print(f"📋 Данные: {json.dumps(schedule_data, indent=2, ensure_ascii=False)[:500]}...")
    else:
        print("❌ Ошибка получения расписания")
        print(schedule_response.text[:300])
    
    # === ПРЕПОДАВАТЕЛИ ===
    print("\n👨‍🏫 Получаем список преподавателей...")
    employees_response = session.get(f"{API_BASE}/employees")
    
    print(f"📥 Статус: {employees_response.status_code}")
    if employees_response.status_code == 200:
        employees_data = employees_response.json()
        print("✅ Список преподавателей получен!")
        if isinstance(employees_data, list):
            print(f"👨‍🏫 Количество преподавателей: {len(employees_data)}")
        else:
            print(f"📋 Данные: {json.dumps(employees_data, indent=2, ensure_ascii=False)[:500]}...")
    else:
        print("❌ Ошибка получения списка преподавателей")
        print(employees_response.text[:300])
    
    print("\n🎯 Тестирование завершено!")
    print("="*60)

if __name__ == "__main__":
    login_and_test_all()