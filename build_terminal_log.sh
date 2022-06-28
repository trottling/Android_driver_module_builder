#!/bin/bash
#-------------Значения переменных-------------#

# Архитектура процессора (arm/arm64)
CPU_ARCHITECTURE=arm64

# Полный путь к тулчейну
COMPILER=/home/xd/kernel_dev/18.1/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

# Файл конфига, находится в arch/arm/configs или в arch/arm64/configs (зависит от архитектуры), например lineage_s2_defconfig
DEFCONFIG=lineage_s2_defconfig

# Путь до папки с драйверами адаптера БЕЗ_ПРОБЕЛОВ, например /home/user/rtl8188eus
ADAPTER_DRIVER_DIR=/home/xd/kernel_dev/18.1/rtl8188eus/


#-------------Запущен ли скрипт под root-------------#

username=$(whoami)
if [ $username != "root" ];then
	echo -e "\033[1m\033[31m Для избежания возможных ошибок, пожалуйста, запустите скрипт от имени root'а"
	exit
fi


#----------------Обновление системы-----------------#

sleep 1

echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Подготовка\033[0m\n"
sleep 1.5

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Обновление системы, для пропуска нажмите Ctrl + C\033[0m\n"
#sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get full-upgrade -y

sleep 1.5


#--------------Добавить доп. репозиторий-------------#

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Проверка наличия репозитория в sources.list"
source="deb http://ftp.debian.org/debian/ stretch main contrib non-free"
path="/etc/apt/sources.list"
found=0
while read line; do
	if [ "$line" == "$source" ];then
		found=1;
		echo -e "\033[1m\033[32m Найдено\033[0m\n"
		break
	fi
done < $path

if [ $found != 1 ];then
	echo -e "\033[1m\033[31m Не найдено \033[0m";echo "Добавление $source в $path\n";echo $source >> $path;
fi

sleep 1.5


#--------------Установить нужные пакеты--------------#

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Установка необходимых пакетов\033[0m\n"
sleep 1.5

sudo apt-get install ark bc bison build-essential clang curl flex g++-multilib gcc gcc-multilib gnupg gperf lib32ncurses-dev lib32z1-dev libc6-dev libc6-dev-i386 libelf-dev libgl1-mesa-dev libssl-dev libx11-dev libxml2-utils make python2 python3 x11proto-core-dev xsltproc zlib1g-dev -y
sleep 1.5


#-------------Очистить ненужные пакеты-------------#

echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Очистка\033[0m\n"
sleep 1.5

sudo apt-get clean -y && sudo apt-get autoremove -y
sleep 1.5


#-------------Переменные-------------#

echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Установка переменных архитектуры и компилятора\033[0m\n"

export ARCH=$CPU_ARCHITECTURE
export SUBARCH=$CPU_ARCHITECTURE
export CROSS_COMPILE=$COMPILER

sleep 1.5

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Считывание /root/.bashrc\033[0m\n"
source /root/.bashrc

sleep 1.5

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Проверка значений переменных\n" 
sleep 1.5

echo -e "	Архитектура: $ARCH"
sleep 0.2

echo -e "	Субархитектура: $SUBARCH"
sleep 0.2

echo -e "	Компилятор: $CROSS_COMPILE\n"
sleep 1.5


#-------------Подготовка-------------#

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Подготовка папки исходников\033[0m\n"
sleep 1.5
sudo make clean && make mrproper

sleep 1

echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Создание файла конфига\033[0m\n"
make $DEFCONFIG

sleep 1

echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Cоздание папки заголовков\033[0m\n"
rm -rf ../kernel-headers
mkdir ../kernel-headers
sleep 1

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Перемещение файла конфига\033[0m\n"

cp .config ../kernel-headers

sleep 1

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Очистка папки исходников ядра\033[0m\n"
make clean && make mrproper



echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Подготовка папки заголовков\033[0m\n"
sleep 1.5

make -j$(nproc --all) O=../kernel-headers modules_prepare
sleep 1.5
make -j$(nproc --all) O=../kernel-headers modules INSTALL_MOD_PATH=../kernel-headers
sleep 1.5
make -j$(nproc --all) O=../kernel-headers modules_install INSTALL_MOD_PATH=../kernel-headers
sleep 1.5
make -j$(nproc --all) headers_install INSTALL_HDR_PATH=../kernel-headers
sleep 1.5

#------------Сборка-------------#

echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Переход в папку драйвера адаптера\033[0m\n"
cd $ADAPTER_DRIVER_DIR

sleep 1.5

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Сборка драйвера адаптера модулем\033[0m\n"

make -j$(nproc --all)


echo -e "\n
\n———————————Not compiled?———————————
⠀⣞⢽⢪⢣⢣⢣⢫⡺⡵⣝⡮⣗⢷⢽⢽⢽⣮⡷⡽⣜⣜⢮⢺⣜⢷⢽⢝⡽⣝
⠸⡸⠜⠕⠕⠁⢁⢇⢏⢽⢺⣪⡳⡝⣎⣏⢯⢞⡿⣟⣷⣳⢯⡷⣽⢽⢯⣳⣫⠇
⠀⠀⢀⢀⢄⢬⢪⡪⡎⣆⡈⠚⠜⠕⠇⠗⠝⢕⢯⢫⣞⣯⣿⣻⡽⣏⢗⣗⠏⠀
⠀⠪⡪⡪⣪⢪⢺⢸⢢⢓⢆⢤⢀⠀⠀⠀⠀⠈⢊⢞⡾⣿⡯⣏⢮⠷⠁⠀⠀
⠀⠀⠀⠈⠊⠆⡃⠕⢕⢇⢇⢇⢇⢇⢏⢎⢎⢆⢄⠀⢑⣽⣿⢝⠲⠉⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡿⠂⠠⠀⡇⢇⠕⢈⣀⠀⠁⠡⠣⡣⡫⣂⣿⠯⢪⠰⠂⠀⠀⠀⠀
⠀⠀⠀⠀⡦⡙⡂⢀⢤⢣⠣⡈⣾⡃⠠⠄⠀⡄⢱⣌⣶⢏⢊⠂⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢝⡲⣜⡮⡏⢎⢌⢂⠙⠢⠐⢀⢘⢵⣽⣿⡿⠁⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠨⣺⡺⡕⡕⡱⡑⡆⡕⡅⡕⡜⡼⢽⡻⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣼⣳⣫⣾⣵⣗⡵⡱⡡⢣⢑⢕⢜⢕⡝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣴⣿⣾⣿⣿⣿⡿⡽⡑⢌⠪⡢⡣⣣⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⡟⡾⣿⢿⢿⢵⣽⣾⣼⣘⢸⢸⣞⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠁⠇⠡⠩⡫⢿⣝⡻⡮⣒⢽⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
------------------------------------\n"
