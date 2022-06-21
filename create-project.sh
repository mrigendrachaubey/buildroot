#/bin/bash
#for any issue in source https://forum.digikey.com/t/debian-getting-started-with-the-beaglebone-black/12967 take help from here.
DIR=$PWD
if [ ! -d "$DIR"/beaglebone-project ]
then
        mkdir beaglebone-project
fi

DIR=$PWD/beaglebone-project

#buildroot
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
chmod a+x $DIR/buildroot/board/beaglebone/post-build.sh

#cross compilers
cd $DIR


export CC_VERSION=10.2.1-2021.04
if [ -d "$DIR"/gcc-arm-$CC_VERSION-x86_64-arm-none-linux-gnueabihf ]
then
        echo "Compiler exists"
        ${CC}gcc --version
else
        cp -R $DIR/../gcc-linaro-10.2.1-2021.04-x86_64_arm-linux-gnueabihf/ $DIR/
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

#kernel
cd $DIR
git clone https://github.com/RobertCNelson/bb-kernel ./kernelbuildscripts
cd kernelbuildscripts/
git checkout origin/am33x-v5.10 -b tmp

sed -i '11i CC=${PWD}/../gcc-linaro-10.2.1-2021.04-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-' system.sh.sample
#remove lines which builds the kernel, just patch the kernel
sed -i '213,228d' build_kernel.sh
./build_kernel.sh
cp -v $DIR/../omap2plus_custom_bbb_defconfig $DIR/kernelbuildscripts/KERNEL/arch/arm/configs/

#now build everything
cd $DIR/buildroot
make beaglebone_exp_defconfig
make -j6
