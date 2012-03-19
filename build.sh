#!/bin/bash


TOP_DIR=$PWD
KERNEL_PATH=/home/pinpong/enigma/enigma-miui-kernel

rm compile.log

TOOLCHAIN="/home/pinpong/android/toolchains/gcc-linaro-arm-linux-gnueabi-2012.02-20120222_linux/bin/arm-linux-gnueabi-"
INITRAMFS_PATH="/home/pinpong/enigma/enigma-miui-initramfs"

export LOCALVERSION="-ENIGMA-1.39"

echo "cleaning latest build"
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN -j`grep 'processor' /proc/cpuinfo | wc -l` clean

echo "set kernel config"
cp -f $KERNEL_PATH/arch/arm/configs/enigma-defconfig $KERNEL_PATH/.config
make -j4 -C $KERNEL_PATH menuconfig || exit -1

echo "make modules"
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN modules_prepare
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN modules
find -name '*.ko' -exec cp -av {} $INITRAMFS_PATH/lib/modules/ \;

echo "make kernel write to compile.log"
make -j4 -C $KERNEL_PATH ARCH=arm CROSS_COMPILE=$TOOLCHAIN >> compile.log 2>&1 || exit -1 

echo "flash kernel via heimdall"
cd /home/pinpong/enigma/enigma-miui-kernel/arch/arm/boot
adb reboot download
sleep 7
sudo heimdall flash --kernel zImage

