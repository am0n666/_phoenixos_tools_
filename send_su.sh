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

if [ -f "$and_sys_root/xbin/su" ]; then
	mv "$and_sys_root/xbin/su" "$and_sys_root/xbin/_su.old"
fi

cp "$DIR/supersu/libsupol.so" "$and_sys_root/lib/"
cp "$DIR/supersu/libsupol.so" "$and_sys_root/lib64/"

cp "$DIR/supersu/su" "$and_sys_root/xbin/"
cp "$DIR/supersu/suinit" "$and_sys_root/xbin/"
cp "$DIR/supersu/sukernel" "$and_sys_root/xbin/"
cp "$DIR/supersu/supolicy" "$and_sys_root/xbin/"

chown 0:0 "$and_sys_root/lib/libsupol.so"
chown 0:0 "$and_sys_root/lib64/libsupol.so"
chown 0:0 "$and_sys_root/xbin/su"
chown 0:0 "$and_sys_root/xbin/suinit"
chown 0:0 "$and_sys_root/xbin/sukernel"
chown 0:0 "$and_sys_root/xbin/supolicy"

chmod 0755 "$and_sys_root/xbin/su"
chmod 0755 "$and_sys_root/xbin/suinit"
chmod 0755 "$and_sys_root/xbin/sukernel"
chmod 0755 "$and_sys_root/xbin/supolicy"

mkdir "$and_sys_root/app/SuperSU"

cp "$DIR/supersu/Superuser.apk" "$and_sys_root/app/SuperSU/SuperSU.apk"

chown -R 0:0 "$and_sys_root/app/SuperSU"
chmod -R 0644 "$and_sys_root/app/SuperSU"









