#/bin/bash
#for any issue in source https://forum.digikey.com/t/debian-getting-started-with-the-beaglebone-black/12967 take help from here.
DIR=$PWD
if [ ! -d "$DIR"/beaglebone-project ]
then
        mkdir beaglebone-project
fi

DIR=$PWD/beaglebone-project

cd $DIR
if [ -d "$DIR"/buildroot ]
then
        echo "buildroot exist"
else
        echo "cloning buildroot"
        git clone git://git.busybox.net/buildroot
        cd buildroot
        git checkout master
fi

#copy changed buildroot to latest buildroot
cd $DIR/..
rsync -avh buildroot/ $DIR/buildroot

#downldad clone cross compiler, now linaro toolchains are hosted on arm website.
#cross compilers from https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads or https://www.linaro.org/downloads/
cd $DIR
#export CC_VERSION=11.2-2022.02
export CC_VERSION=10.2.1-2021.04
if [ -d "$DIR"/gcc-arm-$CC_VERSION-x86_64-arm-none-linux-gnueabihf ]
then
        echo "Compiler exists"
        ${CC}gcc --version
else
        #LINARO_CC_LINK_KERNEL_HEADERS_5_10_x=git@github.com:mrigendrachaubey/gcc-linaro-$CC_VERSION-x86_64_arm-linux-gnueabihf.git
        #git clone $LINARO_CC_LINK_KERNEL_HEADERS_5_10_x
        mv gcc-linaro-10.2.1-2021.04-x86_64_arm-linux-gnueabihf/ $DIR/
        #rm -rf gcc-linaro-$CC_VERSION-x86_64_arm-linux-gnueabihf/
        #tar -xf gcc-linaro-$CC_VERSION-x86_64_arm-linux-gnueabihf.tar.xz
        #LATEST_CC_LINK_KERNEL_HEADERS_4_20_x=https://developer.arm.com/-/media/Files/downloads/gnu/$CC_VERSION/binrel/gcc-arm-$CC_VERSION-x86_64-arm-none-linux-gnueabihf.tar.xz
        #wget $LATEST_CC_LINK 
        #tar -xf gcc-arm-$CC_VERSION-x86_64-arm-none-linux-gnueabihf.tar.xz
        #export CC=$DIR/gcc-arm-$CC_VERSION-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-
        ${CC}gcc --version
fi
export CC=$DIR/gcc-arm-$CC_VERSION-x86_64-arm-linux-gnueabihf/bin/arm-linux-gnueabihf

#uboot
if [ -d "$DIR"/u-boot ]
then
        echo "u-boot exist"
else
        echo "cloning u-boot"
        git clone -b v2022.04 https://github.com/u-boot/u-boot --depth=1
        cd u-boot/
        git pull --no-edit https://git.beagleboard.org/beagleboard/u-boot.git v2022.04-bbb.io-am335x-am57xx
fi

#no need to build u-boot
#make ARCH=arm CROSS_COMPILE=${CC} distclean
#make ARCH=arm CROSS_COMPILE=${CC} am335x_evm_defconfig
#make ARCH=arm CROSS_COMPILE=${CC}

#kernel
cd $DIR
git clone https://github.com/RobertCNelson/bb-kernel ./kernelbuildscripts
cd kernelbuildscripts/
git checkout origin/am33x-v5.10 -b tmp
#Give correct toolchain
#sed -i '9d' system.sh.sample
#sed -i '11i \\t CC=${PWD}/../gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf/gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-' system.sh.sample
sed -i '11i CC=${PWD}/../gcc-linaro-10.2.1-2021.04-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-' system.sh.sample
#remove lines which builds the kernel, just patch the kernel
sed -i '213,228d' build_kernel.sh
./build_kernel.sh
cp -v $DIR/../omap2plus_custom_bbb_defconfig $DIR/kernelbuildscripts/KERNEL/arch/arm/configs/

cd $DIR/buildroot
make beaglebone_exp_defconfig
make -j6
