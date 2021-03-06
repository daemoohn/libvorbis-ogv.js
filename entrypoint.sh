#!/bin/bash

## getting the source code
git clone https://gitlab.xiph.org/xiph/vorbis.git

## get version tag
cd vorbis
version=`git describe --tags`
cd ..

## verify if this specific version has already been uploaded to bintray
bintray_response=`curl -u$1:$2 https://api.bintray.com/packages/daemoohn/libvorbis-ogv.js/libvorbis-ogv.js/versions/$version`
if [[ $bintray_response != *"Version '$version' was not found"* ]]; then
  echo "libvorbis version $version is already present on bintray!"
  exit 1
fi

## getting ogg source code
git clone https://gitlab.xiph.org/xiph/ogg.git

## configureOgg.sh
cd ogg
if [ ! -f configure ]; then
  # generate configuration script
  sed -i.bak 's/$srcdir\/configure/#/' autogen.sh
  ./autogen.sh
fi
cd ..

## compileOggJs.sh
dir=`pwd`

# set up the build directory
mkdir -p build
cd build

mkdir -p js
cd js

mkdir -p root
mkdir -p libogg
cd libogg

# finally, run configuration script
emconfigure ../../../ogg/configure \
    --prefix="$dir/build/js/root" \
    --disable-shared \
|| exit 1

# compile libogg
emmake make -j4 || exit 1
emmake make install || exit 1

cd $dir

## configureVorbis.sh
cd vorbis
if [ ! -f configure ]; then
  # generate configuration script
  # disable running configure automatically
  sed -i.bak 's/$srcdir\/configure/#/' autogen.sh
  ./autogen.sh
  
  # disable oggpack_writealign test
  sed -i.bak 's/$ac_cv_func_oggpack_writealign/yes/' configure
fi
cd ..

## compileVorbisJs.sh
dir=`pwd`

# set up the build directory
mkdir -p build
cd build

mkdir -p js
cd js

mkdir -p root
mkdir -p libvorbis
cd libvorbis
  
# finally, run configuration script
emconfigure ../../../vorbis/configure \
    --disable-oggtest \
    --prefix="$dir/build/js/root" \
    --disable-shared \
|| exit 1

# compile libvorbis
emmake make -j4 || exit 1
emmake make install || exit 1

cd $dir/build/js/root

## upload to bintray
zip -r $dir/libvorbis-ogv.js.zip . 
curl -T $dir/libvorbis-ogv.js.zip -u$1:$2 https://api.bintray.com/content/daemoohn/libvorbis-ogv.js/libvorbis-ogv.js/$version/libvorbis-ogv.js.zip?publish=1
