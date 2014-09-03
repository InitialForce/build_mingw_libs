if [ ! $# -le 5 ]; then
  echo "Usage: $0 ffms2-dir ffmpeg-name 32/64 shared/static release/debug name"
  exit
fi

FFMS2DIR=$1
FFMPEGDIR=$2
BUILDBITS=$3
LINKTYPE=$4
BUILDTYPE=$5
NAME=$6

if  [ "$BUILDBITS" -eq "32" ]; then
  TARGET=i686 
  ARCH=x86
elif [ "$BUILDBITS" -eq "64" ]; then
  TARGET=x86_64
  ARCH=x86_64
  export WINEPREFIX=/home/swingcatalyst/wine_64 
  export WINEARCH=x64
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
elif [ "$LINKTYPE" = "shared" ]; then
  BUILDTYPEPARAMS="--disable-stripping --enable-debug"
fi

BASEDIR=$(dirname $(pwd -P $0)/${0#\.\/})

BUILDNAME=$NAME-$TARGET-$LINKTYPE-$BUILDTYPE


BUILDDIR=$BASEDIR/build/$BUILDNAME-build
INSTALLDIR=$BASEDIR/install/$BUILDNAME-install

FFMPEGBUILDNAME=$FFMPEGDIR-$TARGET-$LINKTYPE-$BUILDTYPE
FFMPEGINSTALLDIR=$BASEDIR/install/$FFMPEGBUILDNAME-install

MXEROOT=$BASEDIR/mxe

echo "Building $BUILDNAME against $FFMPEGDIR ($FFMPEGINSTALLDIR)" 



export PATH=$PATH:$MXEROOT/usr/bin

export PKG_CONFIG_PATH=$BASEDIR/$FFMPEGINSTALLDIR/lib/pkgconfig:$MXEROOT/usr/$ARCH-static-mingw32/lib/pkgconfig

rm -rf $BUILDDIR
mkdir $BUILDDIR
cd $BUILDDIR

export LIBAV_CFLAGS="-I$FFMPEGINSTALLDIR/include"
echo $FFMPEGINSTALLDIR/lib
export LIBAV_LIBS="-L$FFMPEGINSTALLDIR/lib -lswscale-if -lavformat-if -lavcodec-if -lavutil-if -lavdevice-if -lavfilter-if"

export CPPFLAGS="-D_WIN32_WINNT=0x0502 -DWINVER=0x0502"
$BASEDIR/$1/configure \
$LINKTYPEPARAMS \
$BUILDTYPEPARAMS \
--enable-fast-install \
--prefix=$INSTALLDIR \
--host="$TARGET-w64-mingw32.shared" \
--build="$TARGET-w64-mingw32.shared" 
#--with-zlib=$MXEROOT/usr/$ARCH-static-mingw32/ \
#LIBAV_LIBS="
#$BASEDIR/$1/configure \
#--cross-prefix=$TARGET-static-mingw32- \
#--prefix=$INSTALLDIR 

make install
cd ..
