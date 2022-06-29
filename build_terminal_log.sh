#!/bin/bash
#-------------Значения переменных-------------#

# Processor architecture (arm/arm64)
CPU_ARCHITECTURE=arm64

# Full path to the toolchain
COMPILER=/home/xd/kernel_dev/18.1/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

# Configure file located in arch/arm/configs or arch/arm64/configs (architecture dependent), e.g. lineage_s2_defconfig
DEFCONFIG=lineage_s2_defconfig

# Path to adapter drivers folder WITHOUT SPACE, e.g. /home/user/rtl8188eus
ADAPTER_DRIVER_DIR=/home/xd/kernel_dev/18.1/rtl8188eus/


#-------------Whether the script is running under root-------------#

username=$(whoami)
if [ $username != "root" ];then
	echo -e "\033[1m\033[31m To avoid possible errors, please run the script as root"
	exit
fi


#----------------System update-----------------#

sleep 1

echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Preparing\033[0m\n"
sleep 1.5

echo -e "\033[1m\033[34m[\033[31m+\033[34m] System update, press Ctrl + C to skip \033[0m\n"
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get full-upgrade -y

sleep 1.5


#--------------Add additional repository-------------#

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Checking the availability of the repository in sources.list"
source="deb http://ftp.debian.org/debian/ stretch main contrib non-free"
path="/etc/apt/sources.list"
found=0
while read line; do
	if [ "$line" == "$source" ];then
		found=1;
		echo -e "\033[1m\033[32m Found\033[0m\n"
		break
	fi
done < $path

if [ $found != 1 ];then
	echo -e "\033[1m\033[31m Not found \033[0m";echo "Adding $source to $path\n";echo $source >> $path;
fi

sleep 1.5


#--------------Install the required packages--------------#

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Installing the required packages\033[0m\n"
sleep 1.5

sudo apt-get install ark bc bison build-essential clang curl flex g++-multilib gcc gcc-multilib gnupg gperf lib32ncurses-dev lib32z1-dev libc6-dev libc6-dev-i386 libelf-dev libgl1-mesa-dev libssl-dev libx11-dev libxml2-utils make python2 python3 x11proto-core-dev xsltproc zlib1g-dev -y
sleep 1.5


#-------------Clear unnecessary packages-------------#

echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Cleaning\033[0m\n"
sleep 1.5

sudo apt-get clean -y && sudo apt-get autoremove -y
sleep 1.5


#-------------Variables-------------#

echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Setting architecture and compiler variables\033[0m\n"

export ARCH=$CPU_ARCHITECTURE
export SUBARCH=$CPU_ARCHITECTURE
export CROSS_COMPILE=$COMPILER

sleep 1.5

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Read out /root/.bashrc\033[0m\n"
source /root/.bashrc

sleep 1.5

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Checking variable values\n" 
sleep 1.5

echo -e "	Architecture: $ARCH"
sleep 0.2

echo -e "	Subarchitecture: $SUBARCH"
sleep 0.2

echo -e "	Compiler: $CROSS_COMPILE\n"
sleep 1.5


#-------------Preparing-------------#

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Preparing the kernel source folder\033[0m\n"
sleep 1.5
sudo make clean && make mrproper

sleep 1

echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Create .config file\033[0m\n"
make $DEFCONFIG

sleep 1

echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Creating a kernel-header folder\033[0m\n"
rm -rf ../kernel-headers
mkdir ../kernel-headers
sleep 1

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Moving the .config file\033[0m\n"

cp .config ../kernel-headers

sleep 1

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Cleaning kernel-header folder\033[0m\n"
make clean && make mrproper



echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Preparing kernel-header folder\033[0m\n"
sleep 1.5

make -j$(nproc --all) O=../kernel-headers modules_prepare
sleep 1.5
make -j$(nproc --all) O=../kernel-headers modules INSTALL_MOD_PATH=../kernel-headers
sleep 1.5
make -j$(nproc --all) O=../kernel-headers modules_install INSTALL_MOD_PATH=../kernel-headers
sleep 1.5
make -j$(nproc --all) headers_install INSTALL_HDR_PATH=../kernel-headers
sleep 1.5

#------------Build-------------#

echo -e "\n\033[1m\033[34m[\033[31m+\033[34m] Navigate to the adapter driver folder\033[0m\n"
cd $ADAPTER_DRIVER_DIR

sleep 1.5

echo -e "\033[1m\033[34m[\033[31m+\033[34m] Assembling the adapter driver module\033[0m\n"

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
