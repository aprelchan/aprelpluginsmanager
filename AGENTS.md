# Aprel Plugins Manager (APM) — Canary Developer & Agent Guide

Документация платформы: https://plugins.exteragram.app  
Поддерживаемые клиенты: exteraGram / AyuGram / Aprel Gram  

---

## 1. Стиль кода и соглашения

- **Без лишних комментариев**: Пиши чистый, самодокументируемый код без комментариев по шагам, пояснений очевидного и временных пометок (сохранять только авторские атрибуции, если они явно требуются).
- **Модульность**: Строго **не более 2 000 строк** на файл. Разделяй функционал на миксины (`src/mixins/`), хуки (`src/hooks/`), экраны (`src/views/`), аналитику/безопасность (`src/security/`) и совместимость (`src/compat/`).
- **Фасад views**: Миксины/хуки импортируют UI только через `views/__init__.py` (`from ..views import ...`), никогда глубокими путями. Направление зависимостей: `settings -> sheets -> lists`.
- **Безопасность и отказоустойчивость**: Любые хуки, обращение к Java-классам и файловые операции оборачивай в `try...except`. Плагин ни при каких обстоятельствах не должен крашить клиент.
- **Потоки в Android**:
  - Все операции с View/UI строго в `run_on_ui_thread(...)`.
  - Сеть, скачивание и тяжелые парсеры строго в `run_on_queue(...)` или фоновых потоках.
- **Темы и цвета**: Не хардкодить цвета Monet — использовать селекторы и ключи `Theme.getColor(Theme.key_...)`.

---

## 2. Сборка и проверка

- **Проверка синтаксиса Python**:
  ```sh
  python3 -m py_compile apmplugin/src/*.py apmplugin/src/*/*.py
  ```
- **Сборка плагина (`.eaf`)**:
  ```sh
  cd PluginManager-Canary
  uv run --with elyxbuilder-cli elyb build
  ```
  *(Выходной артефакт сохраняется в `builds/AprelPluginsManager.eaf`)*
- **Поднятие версии (bump version)**:
  - Linux/macOS:
    ```sh
    ./scripts/bump-version.sh <версия> [кодовое_имя]
    # Пример: ./scripts/bump-version.sh 1.6.0 "Aprel Chan"
    ```
  - Windows:
    ```cmd
    scripts\bump-version.bat <версия> [кодовое_имя]
    :: Пример: scripts\bump-version.bat 1.6.0 "Aprel Chan"
    ```
  *Синхронно обновляет `metainfo.json`, `src/main.py`, `src/methods.py` и пасхалку.*

---

## 3. Дебаг и логирование

- **Логирование в коде**: Все ключевые события логировать через `log(f"[APM] ...")` из `src.methods`.
- **Логирование исключений и Traceback**: В блоках `except Exception as e` обязательно вызывать `log_error(e, context="...")` или форматировать трейсбек через `traceback.format_exc()` в `log()`, чтобы видеть полный стек ошибки в `latestlog.txt` и logcat.
- **Файл логов**: Логи пишутся в файл `latestlog.txt` (`files/apm/latestlog.txt`) и открываются через `code_viewer.py` (`open_local_file_or_archive` / `open_code_in_article_viewer`) либо нативный `PluginFileViewer` / `ArticleViewer.getInstance()`.
- **Чтение логов через ADB**:
  ```sh
  adb logcat -d | grep -iE "apm"
  ```
- **Очистка логката перед тестом**:
  ```sh
  adb logcat -c
  ```

---

## 4. Архитектура и структура

```
├── refmap.json                  # Маппинг путей для elyxbuilder
├── scripts/                     # Скрипты сборки и версионирования
├── builds/                      # Готовые сборки (*.eaf)
└── apmplugin/
    ├── metainfo.json            # Манифест плагина (id, min_client, icon, requirements)
    ├── locales/                 # Локализация (strings_ru, strings_en, strings_uk, strings_de, strings_fr, strings_es, strings_pt, strings_zh)
    ├── res/                     # Статические ресурсы, svg-иконки, ai_routers, prompt
    │   └── icons/               # SVG-иконки (git, fj, gh, gv, cb, gemini, etc.)
    └── src/
        ├── main.py              # Точка входа AprelPluginsManagerPlugin
        ├── methods.py           # log(), log_error(), open_link(), локализация _tr(), глобальный инстанс
        ├── store.py             # Клиент каталога, зеркала (Forgejo, GitHub, Codeberg, GitVerse)
        ├── sbroka.py            # Экспорт/импорт сборок плагинов
        ├── pill.py              # Интеграция кнопки/пилюли в поисковую строку
        ├── inline_bot.py        # Инлайн-поиск плагинов в чатах (@apm)
        ├── inline_icons.py      # Кэширование и резолв инлайн-стикеров
        ├── inline_btns.py       # Инлайн-кнопки
        ├── elyx_parser.py       # Парсер метаинформации Elyx/EAF
        ├── mixins/              # StoreOpsMixin, InstallerMixin, DialogsMixin, HooksRegistryMixin, FilesMixin
        ├── hooks/               # Хуки lifecycle, UI-интерфейса, настроек, бейджей, Aprel Gram
        ├── views/               # Точка входа `__init__.py` (фасад), слои settings -> sheets -> lists
        │   ├── lists/         # Полноэкранные списки (листья): plugin_list, ai_search, card_menu, pickers
        │   ├── sheets/        # BottomSheet/Dialogs: dialogs, designer, sticker_picker, guide, faq, analysis_sheet, spotlight, code_viewer
        │   └── settings/      # Экран настроек: plugin_settings, icon_selector, dev_cards, debug_settings
        ├── security/            # Анализ байткода DEX/SO (plugin_analysis) и Ed25519 верификация (verify)
        └── compat/              # Слой Java/Android рефлексии (reflection, sender)
```

---

## 5. Специфика клиентов и различия исходников

### Aprel Gram (https://t.me/aprelgram)
- **Java vs Kotlin**: В Aprel Gram большинство компонентов плагинов написаны на Java со статическими методами, а не Kotlin `object` синглтонами.
  - `PluginFileViewer`: `by.aprelteam.plugins.ui.components.PluginFileViewer.open(fragment, file, fileName)` (статический Java-метод, нет поля `INSTANCE`).
  - `MarkdownUtils`: `by.aprelteam.utils.MarkdownUtils` (в exteraGram: `com.exteragram.messenger.utils.MarkdownUtils`).
- **Пакеты и ClassAliases**:
  - Основной пакет клиента: `by.aprelteam.*` (в exteraGram: `com.exteragram.messenger.*`).
  - Класс `ClassAliases` в Aprel Gram транслирует префиксы `com.exteragram.` в `by.aprelteam.`, однако прямой поиск через `find_class` / рефлексию всегда должен иметь fallback на оба пакета.
- **Установка плагинов (Install Sheet)**:
  - BottomSheet установки: `by.aprelteam.plugins.ui.PluginInstallBottomSheet` (обрабатывается в `hooks/install_sheet_aprelgram.py`).
- **Вкладки и PillStack**:
  - Хелпер табов: `by.aprelteam.appearance.MainTabsUiHelper`.
  - PillStack: `by.aprelteam.pillstack.PillStackSettingsActivity`, `PillStackView`.
- **Разрешения (Permissions)**:
  - Aprel Gram строго требует указания всех используемых разрешений в `__permissions__` в `main.py` (`messages.read`, `messages.send`, `network`, `files`, `intents`, `settings`, `hooks`).

### exteraGram / AyuGram
- Пакет: `com.exteragram.messenger.*`.
- Kotlin синглтоны (`object PluginFileViewer` -> `PluginFileViewer.INSTANCE`).
- BottomSheet установки: `com.exteragram.messenger.plugins.ui.components.InstallPluginBottomSheet`.
- AyuGram основан на кодовой базе exteraGram с дополнительными privacy/ghost фичами.

---

## 6. Важные нюансы окружения

1. **SVG и ресурсы**: SVG-файлы из `res/icons/` загружаются через `elyx.assets` с преобразованием в `to_svg_drawable(...)` или `BitmapDrawable`.
2. **Локализация**: Любой новый текстовый ключ обязательно добавляется во все файлы в `locales/`.
3. **Очистка ресурсов (`on_plugin_unload`)**: При выгрузке плагина обязательно вызывать `_unhook_all()`, закрывать открытые диалоги и сбрасывать синглтоны.
4. **Просмотр исходного кода и архивов**: Всегда использовать `views/sheets/code_viewer.py` (`open_local_file_or_archive` / `open_code_in_article_viewer`), который открывает `ArticleViewer.getInstance()` поверх любых BottomSheet и фрагментов настроек.
