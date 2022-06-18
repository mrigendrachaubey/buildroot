#!/bin/sh
BOARD_DIR="$(dirname $0)"
echo "post build script"
KERNEL_UTS=$(cat "$BOARD_DIR/../../output/build/linux-custom/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )
rm -rf $BOARD_DIR/rootfs_overlay/
mkdir -vp $BOARD_DIR/rootfs_overlay/home/utilites/
mkdir -vp $BOARD_DIR/rootfs_overlay/boot/dtbs/$KERNEL_UTS/
mkdir -vp $BOARD_DIR/rootfs_overlay/boot/overlays/
cp -v $BOARD_DIR/uEnv.txt $BOARD_DIR/rootfs_overlay/boot
cp -v $BOARD_DIR/../../output/build/linux-custom/arch/arm/boot/zImage $BOARD_DIR/rootfs_overlay/boot/vmlinuz-$KERNEL_UTS
cp -v $BOARD_DIR/../../output/build/linux-custom/arch/arm/boot/dts/am335x-boneblack-uboot.dtb $BOARD_DIR/rootfs_overlay/boot/dtbs/$KERNEL_UTS
cp -vR $BOARD_DIR/../../output/build/linux-custom/arch/arm/boot/dts/overlays/*.dtbo $BOARD_DIR/rootfs_overlay/boot/overlays
cd $BOARD_DIR/rootfs_overlay/home/utilites/ 
git clone git@github.com:mvduin/bbb-pin-utils.git
cd -
#cp $BOARD_DIR/uEnv.txt $BINARIES_DIR/uEnv.txt
