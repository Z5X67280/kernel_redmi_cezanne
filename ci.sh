#!/bin/bash

# Nitro CI Script
# Copyright (C) 2019 Keternal (Z5X67280@163.com)
# Copyright (C) 2019 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2019 Rama Bondan Prakoso (rama982) 
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Telegram FUNCTION begin
#

git clone https://github.com/fabianonline/telegram.sh telegram

TELEGRAM_ID=-1001394087489
TELEGRAM=telegram/telegram
BOT_API_KEY=723044228:AAFpmF9aHsMTinCJ7Yq3HLxEzjEBiO47rlU
TELEGRAM_TOKEN=${BOT_API_KEY}

export TELEGRAM_TOKEN

# Push kernel installer to channel
function push_package() {
	JIP="Nito-Kernel-$ZIP_VERSION-$BUILD_TYPE-$BUILD_POINT.zip"
	curl -F document=@$JIP  "https://api.telegram.org/bot$BOT_API_KEY/sendDocument" \
	     -F chat_id="$TELEGRAM_ID"
}

function push_md5sum() {
	JIP="md5sum_$(git log --pretty=format:'%h' -1).md5sum"
	curl -F document=@$JIP  "https://api.telegram.org/bot$BOT_API_KEY/sendDocument" \
	     -F chat_id="$TELEGRAM_ID"
}

function push_dtb() {
        JIP="out/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-vince.dtb"
        curl -F document=@$JIP  "https://api.telegram.org/bot$BOT_API_KEY/sendDocument" \
             -F chat_id="$TELEGRAM_ID"
}

# Send the info up
function tg_channelcast() {
	"${TELEGRAM}" -c ${TELEGRAM_ID} -H \
		"$(
			for POST in "${@}"; do
				echo "${POST}"
			done
		)"
}

function tg_sendinfo() {
	curl -s "https://api.telegram.org/bot$BOT_API_KEY/sendMessage" \
		-d "parse_mode=markdown" \
		-d text="${1}" \
		-d chat_id="$TELEGRAM_ID" \
		-d "disable_web_page_preview=true"
}

# Send sticker
function tg_sendstick() {
	curl -s -X POST "https://api.telegram.org/bot$BOT_API_KEY/sendSticker" \
		-d sticker="CAADBQADKgADxKPLIvWZnUrOEg0NAg" \
		-d chat_id="$TELEGRAM_ID" >> /dev/null
}

# Fin prober
function fin() {
	tg_channelcast "<b>Build done!</b>" \
	"Use $(($DIFF / 60)) min $(($DIFF % 60)) sec!" \
	"Make sure you are using Magisk 20.3+!"
}

# Errored prober
function finerr() {
	tg_channelcast "<b>Build fail...</b>" \
	"Check build log to fix compile error!"
	exit 1
}

#
# Telegram FUNCTION end
#

# Build Enviroment

# Build Time Setup
export DATE=`date`
export BUILD_START=$(date "+%s")

# Basic Setup
export ARCH=arm64
export SUBARCH=arm64

# Clang Setup
export CLANG_TRIPLE=aarch64-linux-gnu-
export CC=$PWD/Clang/bin/clang

# Cross Compiler Setup
export CROSS_COMPILE="$PWD/Toolchain/bin/aarch64-linux-android-"
export CROSS_COMPILE_ARM32="$PWD/Toolchain-32/bin/arm-eabi-"

# Customize Build Host and User
export KBUILD_BUILD_USER="Shining Star"
export KBUILD_BUILD_HOST="TNR Drone"

# Defind Kernel Binary
export IMG=$PWD/out/arch/arm64/boot/Image.gz-dtb

# Used for Telegram
export VERSION_TG="GN"
export ZIP_VERSION="GN"
export BUILD_TYPE="REL"

# Install depth for Semaphore

# sudo apt install bc -y

# Compiler Need Python

ln -s /usr/bin/python2 /usr/bin/python

# Telegram Stuff 

# tg_channelcast "#########################"

tg_sendstick

tg_channelcast "<b>Nito Kernel $VERSION_TG</b> new build!" \
		"Stage: <b>Build For Cezanne, Dont flash for vince.</b>" \
		"From <b>Nito Kernel GN</b>" \
		"Under commit <b>$(git log --pretty=format:'%h' -1)</b>"

# Clone Toolchain
git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 --depth=1 Toolchain
git clone https://github.com/arter97/arm32-gcc --depth=1 Toolchain-32
git clone https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-6443078 --depth=1 Clang

# Customize Compiler Name
export KBUILD_COMPILER_STRING=$($CC --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')

# Make Kernel
make O=out cezanne_user_defconfig -j$(grep -c '^processor' /proc/cpuinfo) || finerr
make O=out -j$(grep -c '^processor' /proc/cpuinfo) || finerr

# Calc Build Used Time
export BUILD_END=$(date "+%s")
export DIFF=$(($BUILD_END - $BUILD_START))
export BUILD_POINT=$(git log --pretty=format:'%h' -1)

# Pack
cp $IMG nito-ak3/
cd nito-ak3/
zip -r9 -9 "Nito-Kernel-$ZIP_VERSION-$BUILD_TYPE-$BUILD_POINT.zip" .
md5sum Nito-Kernel-$ZIP_VERSION-$BUILD_TYPE-$BUILD_POINT.zip >> "md5sum_$(git log --pretty=format:'%h' -1).md5sum"

# Push
push_package
push_md5sum
cd ..
# push_dtb
fin
