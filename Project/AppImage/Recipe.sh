#!/bin/bash

#  Copyright (c) MediaArea.net SARL. All Rights Reserved.
#
#  Use of this source code is governed by a GPL v3+ and MPL v2+ license that can
#  be found in the License.html file in the root of the source tree.
#

# This script build qctools and qcli AppImages
# On CentOS 6 host/container this script need the following dependencies:
# file wget tar fuse-libs fuse gcc-c++ pkgconfig libtool automake autoconf
# zlib-devel bzip2-devel qt5-qtbase-devel (from epel repository)

function Make_image() {
    local APP=$1 BIN=$2 DESKTOP=$3 ICON=$4 LOWERAPP=${1,,}

    mkdir -p $LOWERAPP/$LOWERAPP.AppDir
    pushd $LOWERAPP
    pushd $LOWERAPP.AppDir

    mkdir -p usr/bin

    cp $BIN usr/bin/
    cp $DESKTOP $ICON .

    if [ "$ARCH" == "x86_64" ] ; then
        mkdir -p usr/lib64/qt5
        cp -r /usr/lib64/qt5/plugins usr/lib64/qt5
    else
        mkdir -p usr/lib/qt5
        cp -r /usr/lib/qt5/plugins usr/lib/qt5
    fi

    if [ "$LOWERAPP" == "qctools" ] ; then
        get_desktopintegration $LOWERAPP
    fi

    get_apprun
    # Multiple runs to ensure we catch indirect ones
    copy_deps; copy_deps; copy_deps; copy_deps
    move_lib
    delete_blacklisted
    if [ "$ARCH" == "x86_64" ] ; then
        cp -f /usr/lib64/libnss3.so usr/lib64
    else
        cp -f /usr/lib/libnss3.so usr/lib
    fi
    popd
    generate_appimage
    popd
}

VERSION="0.8"

if [ "$(arch)" == "i386" ] ; then
    ARCH="i686"
else
    ARCH="$(arch)"
fi

# Get AppImage utils
curl -L -O https://github.com/probonopd/AppImages/raw/master/functions.sh

# Fix functions.sh
sed -i "s/-x86_64/-$ARCH/g" functions.sh

source ./functions.sh

# Compile QCTools
if test -e qctools/qctools/Project/BuildAllFromSource/build; then
    ./qctools/qctools/Project/BuildAllFromSource/build

    if [ ! -e qctools/qctools/Project/QtCreator/qctools-gui/QCTools ] || [ ! -e qctools/qctools/Project/QtCreator/qctools-cli/qcli ] ; then
        echo Problem while compiling QCTools
        exit 1
    fi
else
    echo qctools directory is not found
    exit 1
fi

# Make appImages
cp qctools/qctools/Source/Resource/Logo.png qctools.png

cat > qcli.desktop <<EOF
[Desktop Entry]
Comment=QCtools command-line utility
Name=qcli
Exec=qcli
Icon=qctools
Terminal=true
Categories=Multimedia;
EOF

Make_image qctools ${PWD}/qctools/qctools/Project/QtCreator/qctools-gui/QCTools \
                   ${PWD}/qctools/qctools/Project/GNU/GUI/qctools.desktop \
                   ${PWD}/qctools.png

Make_image qcli ${PWD}/qctools/qctools/Project/QtCreator/qctools-cli/qcli \
                ${PWD}/qcli.desktop \
                ${PWD}/qctools.png
