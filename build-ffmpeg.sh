#/bin/bash

if [ $# -le 3 ]; then
    echo $#
    echo "Usage: $0 ffmpeg-dir 32/64 shared/static release/debug (name)"
    exit
fi

FFMPEGDIR=$1
BUILDBITS=$2
LINKTYPE=$3
BUILDTYPE=$4
NAME=$5

clean_build=true
do_manual_strip=true
do_copy=true

for opt in "$@"
do
    case "$opt" in
        quick)
            clean_build=false
            ;;
        nostrip)
            do_manual_strip=false
            ;;
        nocopy)
            do_copy=false
            ;;
    esac
done

if [ "$NAME" = "" ]; then
    NAME=$1
fi

if  [ "$BUILDBITS" -eq "32" ]; then
    TARGET=i686-w64-mingw32.shared
    ARCH=i686
elif [ "$BUILDBITS" -eq "64" ]; then
    TARGET=x86_64-w64-mingw32.shared
    ARCH=x86_64
fi

if  [ "$LINKTYPE" = "" ]; then
    LINKTYPE="shared"
    echo "Defaulting to shared build"
fi

if  [ "$BUILDTYPE" = "" ]; then
    BUILDTYPE="release"
fi

if   [ "$LINKTYPE" = "static" ]; then
    LINKTYPEPARAMS="--disable-shared --enable-static"
elif [ "$LINKTYPE" = "shared" ]; then
    LINKTYPEPARAMS="--disable-static --enable-shared"
fi

if   [ "$BUILDTYPE" = "release" ]; then
    BUILDTYPEPARAMS="--disable-debug --enable-stripping"
elif [ "$BUILDTYPE" = "debug" ]; then
    BUILDTYPEPARAMS="--disable-stripping --enable-debug"
    do_manual_strip = false
fi

BASEDIR=$(dirname $(pwd -P $0)/${0#\.\/})

BUILDNAME=$NAME-$TARGET-$LINKTYPE-$BUILDTYPE

echo "Building $BUILDNAME"

BUILDDIR=$BASEDIR/build/$BUILDNAME-build
INSTALLDIR=$BASEDIR/install/$BUILDNAME-install

MXEROOT=$BASEDIR/mxe

export PATH=$PATH:$MXEROOT/usr/bin
PKG_CONFIG_PATH=$MXEROOT/usr/$TARGET/lib/pkgconfig
echo $PKG_CONFIG_PATH

echo "$TARGET-yasm"

if $clean_build ; then
    rm -rf $BUILDDIR
    mkdir $BUILDDIR
    cd $BUILDDIR

        $BASEDIR/$1/configure \
        --cross-prefix=$TARGET- \
        --enable-cross-compile \
        --arch=$ARCH \
        --target-os=mingw32 \
        --prefix=$INSTALLDIR \
        --yasmexe="$TARGET-yasm" \
        $LINKTYPEPARAMS \
        $BUILDTYPEPARAMS \
        --enable-memalign-hack \
        --enable-runtime-cpudetect \
        --disable-pthreads \
        --enable-w32threads \
        --enable-avisynth \
        --enable-bzlib \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libspeex \
        --enable-libtheora \
        --enable-libvorbis \
        --enable-zlib \
        --disable-postproc \
        --build-suffix=-if

        #--enable-libfdk-aac
        #--disable-sse \
            #--disable-sse2 \
            #--disable-asm \
            #--disable-inline-asm
else
    cd $BUILDDIR
fi

echo BUILDING
make -j4 JOBS=4

echo INSTALLING
make install

TARGET_BINDIR=$MXEROOT/usr/$TARGET/bin

for v in "libstdc" "libspeex" "SDL" "libiconv" "libtheora" "libvorbis" "libmp3lame" "zlib" "libbz" "libogg" "libfreetype" "icule" "libffi" "libgcc" "libglib" "libgobject" "libharfbuzz" "libintl" "libpng" "libpcre"; do
    /bin/cp "$TARGET_$BINDIR"/$v*.dll "$INSTALLDIR/bin"
done

if $do_manual_strip ; then
    echo STRIPPING
    $MXEROOT/usr/bin/$TARGET-strip $INSTALLDIR/bin/*.exe
    $MXEROOT/usr/bin/$TARGET-strip $INSTALLDIR/bin/*.dll
fi

cd ..


if $do_copy; then
    echo COPYING
    /bin/cp -r $INSTALLDIR /mnt/WORK/LIBS
fi
