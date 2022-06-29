#!/bin/bash
CURRENT_DATE=`date +%Y%m%d`
CURRENT_TIME=`date +%H-%M-%S`
BUILD_LOG="Module_build_${CURRENT_DATE}_${CURRENT_TIME}.log"
#-------------Variable values-------------#


# Processor architecture (arm/arm64)
CPU_ARCHITECTURE=arm64

# Full path to the toolchain
COMPILER=/home/xd/kernel_dev/18.1/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

# Configure file located in arch/arm/configs or arch/arm64/configs (architecture dependent), e.g. lineage_s2_defconfig
DEFCONFIG=lineage_s2_defconfig

# Path to adapter drivers folder WITHOUT SPACE, e.g. /home/user/rtl8188eus
ADAPTER_DRIVER_DIR=/home/xd/kernel_dev/18.1/rtl8188eus/

#-------------Whether the script is running under root-------------#

function check_root {
username=$(whoami)
if [ $username != "root" ];then
echo -e "	To avoid possible errors, please run the script as root"
exit
fi
}&>>$BUILD_LOG


#----------------System update-----------------#

function update_apt {
echo -e "	Preparing\n"
echo -e "	System update\n"
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get full-upgrade -y
sleep 1.5
}&>>$BUILD_LOG


#--------------Add additional repository-------------#

function update_rep {
echo -e "	Checking the availability of the repository in sources.list"
source="deb http://ftp.debian.org/debian/ stretch main contrib non-free"
path="/etc/apt/sources.list"
found=0
while read line; do
if [ "$line" == "$source" ];then
found=1;
echo -e "	Found\n"
break
fi
done < $path
if [ $found != 1 ];then
echo -e "	Not found";echo "	Adding $source в $path\n";echo $source >> $path;
fi
}&>>$BUILD_LOG

#--------------Install the required packages--------------#

function install_apt {
echo -e "	Installing the required packages\n"

sudo apt-get install ark bc bison build-essential clang curl flex g++-multilib gcc gcc-multilib gnupg gperf lib32ncurses-dev lib32z1-dev libc6-dev libc6-dev-i386 libelf-dev libgl1-mesa-dev libssl-dev libx11-dev libxml2-utils make python2 python3 x11proto-core-dev xsltproc zlib1g-dev -y

}&>>$BUILD_LOG

#-------------Clear unnecessary packages-------------#

function clear_apt {
echo -e "\n	Cleaning\n"
sudo apt-get clean -y && sudo apt-get autoremove -y
}&>>$BUILD_LOG

#-------------Variables-------------#

function export_const {
echo -e "\n	Setting architecture and compiler variables\n"
export ARCH=$CPU_ARCHITECTURE
export SUBARCH=$CPU_ARCHITECTURE
export CROSS_COMPILE=$COMPILER
echo -e "	Read out /root/.bashrc\n"
source /root/.bashrc
echo -e "	Checking variable values\n"

echo -e "	Architecture: $ARCH"
echo -e "	Subarchitecture: $SUBARCH"
echo -e "	Compiler: $CROSS_COMPILE\n"
}&>>$BUILD_LOG

#-------------Preparing-------------#

function pre_install {
echo -e "	Preparing the kernel source folder\n"
sudo make clean && make mrproper
echo -e "\n	Create .config file\n"
make $DEFCONFIG
echo -e "\n	Creating a kernel-header folder\n"
rm -rf ../kernel-headers
mkdir ../kernel-headers
echo -e "	Moving the .config file	\n"
cp .config ../kernel-headers
echo -e "	Cleaning kernel-header folder	\n"
make clean && make mrproper
echo -e "	Preparing kernel-header folderв	\n"
make -j$(nproc --all) O=../kernel-headers modules_prepare
make -j$(nproc --all) O=../kernel-headers modules INSTALL_MOD_PATH=../kernel-headers
make -j$(nproc --all) O=../kernel-headers modules_install INSTALL_MOD_PATH=../kernel-headers
make -j$(nproc --all) headers_install INSTALL_HDR_PATH=../kernel-headers
}&>>$BUILD_LOG

#------------Build-------------#

function build {
echo -e "\n	Navigate to the adapter driver folder	\n"
cd $ADAPTER_DRIVER
echo -e "	Assembling the adapter driver module	\n"
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
