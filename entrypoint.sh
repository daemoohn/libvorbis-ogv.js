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

## tbd