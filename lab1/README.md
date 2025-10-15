# [Скрипт №1](generate_diff_report.sh)

## Описание

Скрипт принимает на вход три параметра: ссылку на удаленный репозиторий, имя ветки 1 и имя ветки 2.

На выходе формирует `txt` файл со списком файлов которые отличаются между ветками.

Файл формируется в формате `diff_report_<BRANCH_1>_vs_<BRANCH_2>.txt` (например, `diff_report_main_vs_develop.txt`).

Отчет содержит структурированную информацию о различиях.

## Пример выходного отчета

```shell
./generate_diff_report.sh https://github.com/pallets/flask stable pass-context
```

```
Cloning repository...
Fetching all branches...
Checking if branches exist...
Calculating differences...
Generating report file...
Cleaning up temporary files...
Report successfully generated: diff_report_stable_vs_pass-context.txt
```

```
Branch Difference Report

================================
Repository:     https://github.com/pallets/flask
Branch 1:       stable
Branch 2:       pass-context
Generated at:   2025-10-06 18:22:49
================================

CHANGED FILES:
M	.github/workflows/tests.yaml
M	CHANGES.rst
M	docs/api.rst
M	docs/appcontext.rst
M	docs/design.rst
M	docs/extensiondev.rst
M	docs/index.rst
M	docs/installation.rst
M	docs/lifecycle.rst
M	docs/patterns/sqlalchemy.rst
M	docs/patterns/sqlite3.rst
M	docs/patterns/streaming.rst
M	docs/quickstart.rst
M	docs/reqcontext.rst
M	docs/shell.rst
M	docs/signals.rst
M	docs/templating.rst
M	docs/testing.rst
M	docs/tutorial/blog.rst
M	docs/tutorial/database.rst
M	docs/tutorial/templates.rst
M	docs/tutorial/tests.rst
M	docs/tutorial/views.rst
M	pyproject.toml
M	src/flask/__init__.py
M	src/flask/app.py
M	src/flask/cli.py
M	src/flask/ctx.py
M	src/flask/debughelpers.py
M	src/flask/globals.py
M	src/flask/helpers.py
M	src/flask/json/__init__.py
M	src/flask/json/provider.py
M	src/flask/sansio/app.py
M	src/flask/sansio/blueprints.py
M	src/flask/sansio/scaffold.py
M	src/flask/templating.py
M	src/flask/testing.py
M	src/flask/typing.py
M	tests/conftest.py
M	tests/test_appctx.py
M	tests/test_blueprints.py
M	tests/test_cli.py
M	tests/test_reqctx.py
M	tests/test_session_interface.py
M	tests/test_subclassing.py
M	tests/test_templating.py
M	tests/test_testing.py
M	uv.lock

STATISTICS:
Total changed files:       49
Added (A):    0
Deleted (D):  0
Modified (M): 49
```

# [Скрипт №2](system_monitor.sh)

## Описание

Скрипт принимает на вход три параметра `START|STOP|STATUS`.

- `START` запускает его в фоне и выдает `PID` процесса;
- `STATUS` выдает состояние - запущен/нет;
- `STOP` - останавливает `PID`.

При запуске скрипт должен проверять, не запущен ли уже другой его экземпляр, чтобы избежать дублирования.

### Основные функции скрипта 

Мониторинг нескольких метрик.

Скрипт должен каждые 10 минут собирать следующие данные:

- Память: общий объем, свободный объем, процент использования.
- ЦПУ: общая загрузка процессора (в процентах).
- Диск: использование корневого раздела (/) в процентах.
- Нагрузка: средняя нагрузка на систему за 1 минуту.

Скрипт должен записывать данные в `csv`-файл с именем `system_report_YYYY-MM-DD.csv` (где `YYYY-MM-DD` - текущая дата).

Формат строки:
`timestamp;all_memory;free_memory;%memory_used;%cpu_used;%disk_used;load_average_1m`

## Пример выходного csv-файла

`logs/system_report_2025-10-06.csv`

```
timestamp;all_memory;free_memory;%memory_used;%cpu_used;%disk_used;load_average_1m
2025-10-06 19:13:28;16384;5863;64.22;13.9;9;1.20
2025-10-06 19:23:28;16384;5759;64.85;10.06;9;1.39
2025-10-06 19:29:14;16384;5761;64.84;10.15;9;1.23
2025-10-06 19:39:15;16384;5887;64.07;13.76;9;1.47
```

# [Скрипт №3](error_extractor.sh)

## Описание

Скрипт принимает:
- первым аргументом имя лог-файла;
- вторым аргументом ключевое слово для поиска (например, `"ERROR"`).

На выходе два файла:
- Считает и выводит количество найденных ошибок.
- Сохраняет сами эти ошибки в новый файл.

Формат вывода свободный.

## Пример вывода

```shell
./error_extractor.sh test_log.txt ERROR
```

```
Searching for keyword 'ERROR' in file 'test_log.txt'...
Number of errors found:        2 (saved in 'errors_count.txt')
All errors have been saved to 'errors_found.txt'
```
