#!/usr/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function nout() {
	"$@" >/dev/null 2>&1
}

function extract_files() {
	local file_list=""

	file_list="${file_list} $(7z l -ba "$1" | grep -oP '\S+$' | grep kernel)"
	file_list="${file_list} $(7z l -ba "$1" | grep -oP '\S+$' | grep system)"
	file_list="${file_list} initrd.img ramdisk.img"

	echo ""
	echo "Extracting files:"

	for file in ${file_list}; do
		echo "$file"
		nout 7z e "$1" -o"$DESTINADION_PATH" "$file" -r
	done
}

if [ ! -f "$DIR/config" ]; then
	echo "Config file not found:"
	echo "$DIR/config"
	exit
fi

source "$DIR/config"

if [ ! -d "$DESTINADION_PATH" ]; then
	mkdir -p "$DESTINADION_PATH"
else
	echo "Directory already exists: " "$DESTINADION_PATH"
	exit
fi

if [ ! -n "$1" ]; then
	echo "Usage:"
	echo "install.sh <iso_file_path>"
	exit
fi

iso_file="$1"

if [ ! -f "$iso_file" ]; then
	echo "Iso file not found:"
	echo "$iso_file"
	exit
fi


extract_files "$1"

touch "$DESTINADION_PATH/findme"
mkdir -p "$DESTINADION_PATH/data"

function install_magisk() {
	mkdir "$DIR/magisk_install_tmp"
	
	mv "$DESTINADION_PATH/ramdisk.img" "$DESTINADION_PATH/ramdisk.img.old"
	cp "$DESTINADION_PATH/ramdisk.img.old" "$DIR/magisk_install_tmp/ramdisk.img"
	cp "$DIR/tools/magisk/rusty-magisk" "$DIR/magisk_install_tmp/"
	chmod 0755 "$DIR/magisk_install_tmp/rusty-magisk"
	
	cd "$DIR/magisk_install_tmp"

	mkdir ramdisk && ( cd ramdisk && zcat ../ramdisk.img | cpio -iud && mv init init.real )
	rsync rusty-magisk ramdisk/init && chmod 777 ramdisk/init && ( cd ramdisk && find . | cpio -o -H newc | gzip > ../ramdisk.img )

	cp "$DIR/magisk_install_tmp/ramdisk.img" "$DESTINADION_PATH/"
	
	mkdir -p "$DESTINADION_PATH/data/app/com.topjohnwu.magisk-1"
	cp "$DIR/tools/magisk/Magisk.apk" "$DESTINADION_PATH/data/app/com.topjohnwu.magisk-1/"

	cd "$DIR"

	rm -rf "$DIR/magisk_install_tmp"
}

if [ "$INSTALL_RUSTY_MAGISK" == "1" ]; then
	echo ""
	echo "Installing rusty magisk"
	install_magisk
fi

function install_leatest_gearlock() {
	GL_DIR="$DIR/gearlock"
	git clone https://github.com/axonasif/gearlock.git "$GL_DIR"
	
	cd "$GL_DIR"
	bash makeme
	
	if [ ! -f "$GL_DIR/out/installer/gearlock" ]; then
		echo ""
		echo "Compiling gearlock error!"
		echo "Cannot install gearlock"
		cd "$DIR"
		rm -rf "$GL_DIR"
		exit
	fi

	mv "$DESTINADION_PATH/initrd.img" "$DESTINADION_PATH/bootinstall-initrd.img"
	cp "$GL_DIR/out/installer/gearlock" "$DESTINADION_PATH/bootinstall-gearlock"
	cp "$GL_DIR/out/installer/initrd.img" "$DESTINADION_PATH/initrd.img"

	cd "$DIR"
	rm -rf "$GL_DIR"
}

if [ "$MAKE_LEATEST_GEARLOCK_BOOT_INSTALLER" == "1" ]; then
	echo ""
	echo "Installing leatest gearlock"
	install_leatest_gearlock
fi











