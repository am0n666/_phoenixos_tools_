DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function _error() {
	echo "Error:"
	echo "$@"
	exit
}

function convert_path() {
	_input="$1"
	_output=""
	_fch_=$(printf %.1s "$_input")
	[ "$_fch_" = "/" ] && _output+="$_input"
	[ ! "$_fch_" = "/" ] && _output+="`pwd`/$_input"
	_lch_=${_output:$((${#_output}-1)):1}
	[ "$_lch_" = "/" ] && _output="${_output:0:${#_output}-1}"
	echo $_output
}

function show_usage() {
	echo "
Usage:
	gen_grub_menu.sh <output_file_path> <android_name> <android_root> <android_os_dir>
"
exit
}

if [ ! -n "$1" ] || [ ! -n "$2" ] || [ ! -n "$3" ] || [ ! -n "$4" ]; then
	show_usage
fi

# 1 Grub output file path
# 2 Android name
# 3 Android root
# 4 Android os directory

out_file_path="$(convert_path "$1")"
android_menuentry_name="$2"
android_root="($3)"
android_osdir="$4"

nouveau="i915.modeset=0 nouveau.modeset=1"
vulkan="HWACCEL=1 HWCOMP=1 VULKAN=android-x86 VULKAN=radv VULKAN=1 VULKAN=nvidia"
adtional_cpu_flags="noibrs noibpb nopti nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable no_stf_barrier mds=off tsx=on tsx_async_abort=off mitigations=off"


echo "# Generated Grub Menu
set gfxpayload=SCREENxRESOLUTION
set _root=$android_root
set osdir=$android_osdir

export gfxpayload _root osdir

insmod all_video

set timeout=30

set default=0

function savelast {
	return 0
}

menuentry '$android_menuentry_name - Start with standard flags'  --class other {
	set root=\$_root
	linux \$osdir/kernel NORECOVERY=0 VIRT_WIFI=0 root=/dev/ram0 androidboot.selinux=permissive quiet acpi_sleep=s3_bios,s3_mode SRC=\$osdir
	initrd \$osdir/initrd.img
}

menuentry '$android_menuentry_name - Start with adtional cpu flags'  --class other {
	set root=\$_root
	linux \$osdir/kernel NORECOVERY=0 VIRT_WIFI=0 root=/dev/ram0 androidboot.selinux=permissive $adtional_cpu_flags quiet acpi_sleep=s3_bios,s3_mode SRC=\$osdir
	initrd \$osdir/initrd.img
}

menuentry '$android_menuentry_name - Start with nouveau'  --class other {
	set root=\$_root
	linux \$osdir/kernel NORECOVERY=0 VIRT_WIFI=0 root=/dev/ram0 androidboot.selinux=permissive quiet acpi_sleep=s3_bios,s3_mode $nouveau SRC=\$osdir
	initrd \$osdir/initrd.img
}

menuentry '$android_menuentry_name - Start with nouveau and adtional cpu flags'  --class other {
	set root=\$_root
	linux \$osdir/kernel NORECOVERY=0 VIRT_WIFI=0 root=/dev/ram0 androidboot.selinux=permissive quiet acpi_sleep=s3_bios,s3_mode $adtional_cpu_flags $nouveau SRC=\$osdir
	initrd \$osdir/initrd.img
}


menuentry '$android_menuentry_name - Start with nouveau and vulkan'  --class other {
	set root=\$_root
	linux \$osdir/kernel NORECOVERY=0 VIRT_WIFI=0 root=/dev/ram0 androidboot.selinux=permissive quiet acpi_sleep=s3_bios,s3_mode $nouveau $vulkan SRC=\$osdir
	initrd \$osdir/initrd.img
}

menuentry '$android_menuentry_name - Start with nouveau and vulkan and adtional cpu flags'  --class other {
	set root=\$_root
	linux \$osdir/kernel NORECOVERY=0 VIRT_WIFI=0 root=/dev/ram0 androidboot.selinux=permissive quiet acpi_sleep=s3_bios,s3_mode $adtional_cpu_flags $nouveau $vulkan SRC=\$osdir
	initrd \$osdir/initrd.img
}

menuentry '$android_menuentry_name - Boot into Revovery'  --class other {
	set root=\$_root
	linux \$osdir/kernel ALWAYSRECOVERY=0 root=/dev/ram0 androidboot.selinux=permissive quiet acpi_sleep=s3_bios,s3_mode SRC=\$osdir
	initrd \$osdir/initrd.img
}

" > "$out_file_path"





















