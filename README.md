Select your language in branch
# Android driver module builder
Автор: Я, с чем то помог SurvivalHorror
Последняя доработка: ещё не было


# Скрипт собирает модулем драйвер wi-fi адаптера с нужным заголовком ядра

Что нужно для работы:
+ Линукс
+ Интернет
+ Исходники ядра
+ Исходники нужных драйверов


 # Как пользоваться
 
1. Качаем файлы
```
https://github.com/trottling/Android_driver_module_builder -b rus
```

2. Берем нужную нам версию

```
    С логом в терминал build_terminal_log.sh
    С логом в файл build_file_log.sh
```


3. Кидаем в папку с исходниками ядра

4. Открываем и редактируем под себя:

```
#-------------Значения переменных-------------#

# Архитектура процессора (arm/arm64)
CPU_ARCHITECTURE=arm64

# Полный путь к тулчейну
COMPILER=/home/xd/kernel_dev/18.1/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

# Файл конфига, находится в arch/arm/configs или в arch/arm64/configs (зависит от архитектуры), например lineage_s2_defconfig
DEFCONFIG=lineage_s2_defconfig

# Путь до папки с драйверами адаптера БЕЗ_ПРОБЕЛОВ, например /home/user/rtl8188eus
ADAPTER_DRIVER_DIR=/home/xd/kernel_dev/18.1/rtl8188eus/
```

5. Запускаем от имени рута и смотрим лог
