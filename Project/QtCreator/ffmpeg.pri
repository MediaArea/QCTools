macx:contains(DEFINES, USE_BREW) {
    message("use ffmpeg from brew")

    PKGCONFIG += libavdevice libavcodec libavfilter libavformat libpostproc
    PKGCONFIG += libswresample libswscale libavcodec libavutil

    CONFIG += link_pkgconfig

} else {
    FFMPEG_PATH = $$absolute_path($$PWD/../../../ffmpeg)
    message("add external ffmpeg " $$FFMPEG_PATH )

    INCLUDEPATH += $$FFMPEG_PATH

    LIBS      += -L$$FFMPEG_PATH/libavdevice -lavdevice \
                 -L$$FFMPEG_PATH/libavcodec -lavcodec \
                 -L$$FFMPEG_PATH/libavfilter -lavfilter \
                 -L$$FFMPEG_PATH/libavformat -lavformat \
                 -L$$FFMPEG_PATH/libpostproc -lpostproc \
                 -L$$FFMPEG_PATH/libswresample -lswresample \
                 -L$$FFMPEG_PATH/libswscale -lswscale \
                 -L$$FFMPEG_PATH/libavcodec -lavcodec \
                 -L$$FFMPEG_PATH/libavutil -lavutil

    win32 {
        contains(QMAKE_TARGET.arch, x86_64) {
            LIBS += -L$$FFMPEG_PATH/../freetype/objs/vc2010/x64 -lfreetype271
        } else {
            LIBS += -L$$FFMPEG_PATH/../freetype/objs/vc2010/Win32 -lfreetype271
        }
    } else {
        LIBS += -L$$FFMPEG_PATH/../freetype/usr/lib -lfreetype
    }
}
