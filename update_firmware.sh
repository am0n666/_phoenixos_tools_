DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -n "$1" ]; then
	exit
fi

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

and_sys_root="$(convert_path "$1")"

if [ ! -d "$and_sys_root" ]; then
	_error "Directory not found: $and_sys_root"
fi

if [ ! -f "$and_sys_root/build.prop" ]; then
	_error "It's not android root directory"
fi

function update_firmware() {

	clear
	echo ""
	echo "Updating linux firmware, please wait."
	git clone https://kernel.googlesource.com/pub/scm/linux/kernel/git/firmware/linux-firmware "$DIR/firmware"
	rm -rf "$DIR/firmware/.git"
	mv -f "$and_sys_root/lib/firmware" "$and_sys_root/lib/firmware.old"
	mv -f "$DIR/firmware" "$and_sys_root/lib"
	echo ""
	echo "Done"
	echo ""
}

update_firmware "$and_sys_root"

