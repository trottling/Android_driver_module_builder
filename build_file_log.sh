#!/bin/bash
CURRENT_DATE=`date +%Y%m%d`
CURRENT_TIME=`date +%H-%M-%S`
BUILD_LOG="Module_build_${CURRENT_DATE}_${CURRENT_TIME}.log"
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

function check_root {
username=$(whoami)
if [ $username != "root" ];then
echo -e "	Для избежания возможных ошибок, пожалуйста, запустите скрипт от имени root'а"
exit
fi
}&>>$BUILD_LOG


#----------------Обновление системы-----------------#

function update_apt {
echo -e "	Подготовка\n"
echo -e "	Обновление системы\n"
#sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get full-upgrade -y
sleep 1.5
}&>>$BUILD_LOG


#--------------Добавить доп. репозиторий-------------#

function update_rep {
echo -e "	Проверка наличия репозитория в sources.list"
source="deb http://ftp.debian.org/debian/ stretch main contrib non-free"
path="/etc/apt/sources.list"
found=0
while read line; do
if [ "$line" == "$source" ];then
found=1;
echo -e "	Найдено\n"
break
fi
done < $path
if [ $found != 1 ];then
echo -e "	Не найдено";echo "	Добавление $source в $path\n";echo $source >> $path;
fi
}&>>$BUILD_LOG

#--------------Установить нужные пакеты--------------#

function install_apt {
echo -e "	Установка необходимых пакетов\n"

sudo apt-get install ark bc bison build-essential clang curl flex g++-multilib gcc gcc-multilib gnupg gperf lib32ncurses-dev lib32z1-dev libc6-dev libc6-dev-i386 libelf-dev libgl1-mesa-dev libssl-dev libx11-dev libxml2-utils make python2 python3 x11proto-core-dev xsltproc zlib1g-dev -y

}&>>$BUILD_LOG

#-------------Очистить ненужные пакеты-------------#

function clear_apt {
echo -e "\n	Очистка\n"
sudo apt-get clean -y && sudo apt-get autoremove -y
}&>>$BUILD_LOG

#-------------Переменные-------------#

function export_const {
echo -e "\n	Установка переменных архитектуры и компилятора\n"
export ARCH=$CPU_ARCHITECTURE
export SUBARCH=$CPU_ARCHITECTURE
export CROSS_COMPILE=$COMPILER
echo -e "	Считывание /root/.bashrc\n"
source /root/.bashrc
echo -e "	Проверка значений переменных\n"

echo -e "	Архитектура: $ARCH"
echo -e "	Субархитектура: $SUBARCH"
echo -e "	Компилятор: $CROSS_COMPILE\n"
}&>>$BUILD_LOG

#-------------Подготовка-------------#

function pre_install {
echo -e "	Подготовка папки исходников\n"
sudo make clean && make mrproper
echo -e "\n	Создание файла конфига\n"
make $DEFCONFIG
echo -e "\n	Cоздание папки заголовков\n"
rm -rf ../kernel-headers
mkdir ../kernel-headers
echo -e "	Перемещение файла конфига	\n"
cp .config ../kernel-headers
echo -e "	Очистка папки исходников	\n"
make clean && make mrproper
echo -e "	Подготовка папки заголовков	\n"
make -j$(nproc --all) O=../kernel-headers modules_prepare
make -j$(nproc --all) O=../kernel-headers modules INSTALL_MOD_PATH=../kernel-headers
make -j$(nproc --all) O=../kernel-headers modules_install INSTALL_MOD_PATH=../kernel-headers
make -j$(nproc --all) headers_install INSTALL_HDR_PATH=../kernel-headers
}&>>$BUILD_LOG

#------------Сборка-------------#

function build {
echo -e "\n	Переход в папку драйвера адаптера	\n"
cd $ADAPTER_DRIVER
echo -e "	Сборка драйвера адаптера модулем	\n"
make -j$(nproc --all) CROSS_COMPILE=$COMPILER
}&>>$BUILD_LOG

#------------------------------------#
check_root
update_apt
update_rep
install_apt
clear_apt
export_const
pre_install
build 
#------------------------------------#
