#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 ffmpegbranch"
  exit
fi

BRANCH=$1

formattedbranch="${BRANCH//\//-}"-`eval date +%Y%m%d`
echo $formattedbranch

echo BUILDING FFMPEG 32
./build-ffmpeg.sh FFmpeg 32 shared release FFmpeg-$formattedbranch
echo BUILDING FFMS 32
./build-ffms2.sh ffms2 FFmpeg-$formattedbranch 32 shared release ffms2-$formattedbranch


echo BUILDING FFMPEG 64
./build-ffmpeg.sh FFmpeg 64 shared release FFmpeg-$formattedbranch
echo BUILDING FFMS 64
./build-ffms2.sh ffms2 FFmpeg-$formattedbranch 64 shared release ffms2-$formattedbranch
