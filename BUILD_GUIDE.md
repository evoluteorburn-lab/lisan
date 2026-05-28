# Lisan — Сборка APK для Android

## Требования

1. **Flutter SDK** (>=3.0.0)
   - Скачать: https://docs.flutter.dev/get-started/install
   - Добавить в PATH

2. **Android Studio**
   - Установить Android SDK
   - Установить Android SDK Command-line tools
   - Принять лицензии: `flutter doctor --android-licenses`

3. **Java JDK** (17 или 21)

## Проверка окружения

```bash
flutter doctor
```

Должно быть:
- ✅ Flutter SDK
- ✅ Android toolchain
- ✅ Android Studio
- ✅ Connected device (или эмулятор)

## Шаги сборки

### 1. Клонировать проект

```bash
git clone <url> lisan
cd lisan
```

Или скачать ZIP и распаковать.

### 2. Установить зависимости

```bash
flutter pub get
```

### 3. Настроить API ключи

Создать файл `assets/.env` (или отредактировать существующий):

```
DEEPL_API_KEY=your_deepl_key_here
DEEPSEEK_API_KEY=your_deepseek_key_here
ELEVENLABS_API_KEY=your_elevenlabs_key_here
OPENAI_API_KEY=your_openai_key_here
```

**Важно:** Для теста можно захардкодить ключи в `lib/services/translation_service.dart`, но перед публикацией обязательно вынести в `.env`.

### 4. Подключить телефон

- Включить **USB-отладку** на телефоне (Настройки → Для разработчиков)
- Подключить к компьютеру USB
- Разрешить отладку с этого компьютера

Проверить:
```bash
flutter devices
```

### 5. Запустить на телефоне

```bash
flutter run
```

Или собрать APK:
```bash
flutter build apk --release
```

APK будет в:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 6. Установить APK на телефон

```bash
flutter install
```

Или скопировать APK на телефон и установить вручную.

## Решение проблем

### Ошибка: "No connected devices"
- Проверить USB-кабель (не зарядный, а data-кабель)
- Включить USB-отладку
- Установить драйверы Google USB Driver (Windows)

### Ошибка: "Gradle failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### Ошибка: "SDK not found"
- Установить Android SDK через Android Studio
- Установить переменную `ANDROID_HOME`

## Тестирование

После установки:
1. Открыть приложение "Lisan"
2. Разрешить доступ к микрофону
3. Нажать большую кнопку микрофона
4. Сказать фразу на русском
5. Отпустить кнопку
6. Ждать 3-10 секунд
7. Услышать перевод на арабском

## Следующие шаги после теста

- [ ] Проверить скорость на мобильном интернете (не WiFi)
- [ ] Проверить работу в фоне
- [ ] Проверить расход батареи
- [ ] Собрать feedback от пользователей
- [ ] Подготовить к публикации в Google Play

## Контакты

По вопросам: обратиться к разработчику.
