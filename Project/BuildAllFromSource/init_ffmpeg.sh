#! /bin/bash

echo "PWD: " + $PWD

_install_yasm(){
    wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
    tar -zxvf yasm-1.3.0.tar.gz
    rm yasm-1.3.0.tar.gz
    mv yasm-1.3.0 yasm
}

if [ ! -d freetype ] ; then
    wget https://downloads.sf.net/project/freetype/freetype2/2.7.1/freetype-2.7.1.tar.bz2
    tar jxf freetype-2.7.1.tar.bz2
    mv freetype-2.7.1 freetype
fi

if sw_vers >/dev/null 2>&1 ; then
    export CFLAGS="$CFLAGS -mmacosx-version-min=10.5"
    export CXXFLAGS="$CXXFLAGS -mmacosx-version-min=10.5"
fi

cd freetype
chmod u+x configure
./configure --prefix="`pwd`/usr" --without-zlib --without-bzip2 --without-png --without-harfbuzz --enable-static --disable-shared
make
make install
cd ..

if [ ! -d ffmpeg ] ; then
    git clone --depth 1 git://source.ffmpeg.org/ffmpeg.git ffmpeg
fi

    cd ffmpeg
    FFMPEG_CONFIGURE_OPTS=(--enable-gpl --enable-version3 --disable-programs --disable-securetransport --disable-videotoolbox --disable-shared --enable-static --disable-doc --disable-ffplay --disable-ffprobe --disable-ffserver --disable-debug --disable-lzma --disable-iconv --enable-pic --enable-libfreetype --extra-cflags=-I../freetype/include)
    chmod u+x configure
    chmod u+x version.sh
    if yasm --version >/dev/null 2>&1 ; then
        ./configure "${FFMPEG_CONFIGURE_OPTS[@]}"
        if [ "$?" -ne 0 ] ; then #on some distro, yasm version is too old
            cd "$INSTALL_DIR"
            if [ ! -d yasm ] ; then
                _install_yasm
            fi
            cd yasm/
            ./configure --prefix=`pwd`/usr
            make
            make install
            cd "${INSTALL_DIR}/ffmpeg"
            FFMPEG_CONFIGURE_OPTS+=(--yasmexe=../yasm/usr/bin/yasm)
            ./configure "${FFMPEG_CONFIGURE_OPTS[@]}"
        fi
    else
        cd "$INSTALL_DIR"
        if [ ! -d yasm ] ; then
            _install_yasm
        fi
        cd yasm/
        ./configure --prefix=`pwd`/usr
        make
        make install
        cd "${INSTALL_DIR}/ffmpeg"
        FFMPEG_CONFIGURE_OPTS+=(--yasmexe=../yasm/usr/bin/yasm)
        ./configure "${FFMPEG_CONFIGURE_OPTS[@]}"
    fi
    make
    cd "$INSTALL_DIR"
