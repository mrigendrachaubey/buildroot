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


#downldad clone cross compiler, now linaro toolchains are hosted on arm website.
#cross compilers from https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads or https://www.linaro.org/downloads/
cd $DIR
export CC_VERSION=11.2-2022.02
if [ -d "$DIR"/gcc-arm-$CC_VERSION-x86_64-arm-none-linux-gnueabihf ]
then
        echo "Compiler exists"
        ${CC}gcc --version
else
        #LINARO_CC_LINK=git@github.com:mrigendrachaubey/gcc-linaro-10.2.1-2021.04-x86_64_arm-linux-gnueabihf.git
        #git clone $LINARO_CC_LINK
        LATEST_CC_LINK=https://developer.arm.com/-/media/Files/downloads/gnu/$CC_VERSION/binrel/gcc-arm-$CC_VERSION-x86_64-arm-none-linux-gnueabihf.tar.xz
        wget $LATEST_CC_LINK 
        tar -xf gcc-arm-$CC_VERSION-x86_64-arm-none-linux-gnueabihf.tar.xz
fi

export CC=$DIR/gcc-arm-$CC_VERSION-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-


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
cd u-boot/
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} am335x_evm_defconfig
make ARCH=arm CROSS_COMPILE=${CC}

#kernel
cd $DIR
git clone https://github.com/RobertCNelson/bb-kernel ./kernelbuildscripts
cd kernelbuildscripts/
sed -i '9i \\t CC=DIR/gcc-arm-$CC_VERSION-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-' system-test.sh
git checkout origin/am33x-v5.10 -b tmp
./build_kernel.sh
