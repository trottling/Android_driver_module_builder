Select your language in branch
# Android driver module builder
Author: Me, something SurvivalHorror helped with
Last update: Hasn't been done yet


# The script builds a wi-fi adapter driver module with the correct kernel header

What is needed to work:
+ Linux
+ Internet
+ Kernel source code
+ The right drivers source code


 # How to use
 
1. Download the files
```
https://github.com/trottling/Android_driver_module_builder -b rus
```

2.

```
    With log into terminal build_terminal_log.sh
    With log into build_file_log.sh
```


3. Put it in the folder with the kernel sources

4. open and edit for your needs:

```
#-------------Variable values-------------#

# Processor architecture (arm/arm64)
CPU_ARCHITECTURE=arm64

# Full path to the tolchain
COMPILER=/home/xd/kernel_dev/18.1/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

# Configure file located in arch/arm/configs or in arch/arm64/configs (depends on the architecture), e.g. lineage_s2_defconfig
DEFCONFIG=lineage_s2_defconfig

# Path to adapter drivers folder WITHOUT SPACE, e.g. /home/user/rtl8188eus
ADAPTER_DRIVER_DIR=/home/xd/kernel_dev/18.1/rtl8188eus/
```

5. Run as root and see the log


Translated with DeepL
