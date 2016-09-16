#!/bin/bash
set -x
set -e
script_name=${0##*/}
script_dir=$(dirname $(readlink -f "$0"))

usage()
{
cat  << EOT
$script_name - create a basic template to start an autotools project

Usage: $script_name [options] project_name

Options:
	-h	: show this help
EOT
}

create_configure_ac()
{
	export CONFIGURE_AC="$project_name/configure.ac"

	cat << EOT > "$CONFIGURE_AC"
AC_INIT([$project_name], 0.1)
AM_INIT_AUTOMAKE([foreign -Wall -Werror subdir-objects])
AM_SILENT_RULES([yes])
AC_CONFIG_SRCDIR([src/main.c])
AC_CONFIG_MACRO_DIR([m4])
AC_PROG_CC
AC_CONFIG_FILES(Makefile)
AC_OUTPUT
EOT
}

create_makefile_am()
{
	export MAKEFILE_AM="$project_name/Makefile.am"
	cat << EOT > "$MAKEFILE_AM"
bin_PROGRAMS = $project_name
${project_name}_SOURCES = src/main.c
EOT
}


create_autogen_sh()
{
	export AUTOGEN_SH="$project_name/autogen.sh"
	cat << EOT > "$AUTOGEN_SH"
autoreconf --force --install --symlink --warnings=all
set -x
./configure $args "$@"
make clean
EOT
	chmod +x "$AUTOGEN_SH"
}

while getopts "h" opt
do
	case "$opt" in
		h)
			usage
			exit 0
			;;
	esac
done

shift $(($OPTIND - 1))

project_name="$1"

mkdir "$project_name"

create_configure_ac

# run aclocal and autoconf
pushd "$project_name"
mkdir  m4
aclocal
autoconf
popd

#create src dir
export SRC_DIR="$project_name/src"
mkdir "$SRC_DIR"
cp "$script_dir/data/main.c" "$SRC_DIR/main.c"

create_makefile_am
create_autogen_sh
