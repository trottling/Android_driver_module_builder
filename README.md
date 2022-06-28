# Android_driver_module_builder
Автор: Я, с чем то помог SurvivalHorror
Последняя доработка: ещё не было

 
Что нам нужно
Линукс
Интернет
Исходники ядра, и нужных драйверов

 
Как пользоваться
Качаем нужный файл, кидаем в папку с исходниками ядра, открываем:

#-------------Значения переменных-------------#

# Архитектура процессора (arm/arm64)
CPU_ARCHITECTURE=arm64

# Полный путь к тулчейну
COMPILER=/home/xd/kernel_dev/18.1/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

# Файл конфига, находится в arch/arm/configs или в arch/arm64/configs (зависит от архитектуры), например lineage_s2_defconfig
DEFCONFIG=lineage_s2_defconfig

# Путь до папки с драйверами адаптера БЕЗ_ПРОБЕЛОВ, например /home/user/rtl8188eus
ADAPTER_DRIVER_DIR=/home/xd/kernel_dev/18.1/rtl8188eus/


Меняем на своё и запускаем от имени рута (ну не на шиндовсе же это делать)


Есть два стула:

    С логом в терминал build_terminal_log.sh
    С логом в файл build_file_log.sh
