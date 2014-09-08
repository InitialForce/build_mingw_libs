#!/bin/bash

BRANCH=$1

formattedbranch="${BRANCH//\//-}"-`eval date +%Y%m%d`
echo formattedbranch

./build-ffmpeg.sh FFmpeg 32 shared release FFmpeg-$formattedbranch
./build-ffmpeg.sh FFmpeg1 64 shared release FFmpeg-$formattedbranch

./build-ffms2.sh ffms2 32 shared release ffms2-$formattedbranch
./build-ffms.sh ffms2 64 shared release ffms2-$formattedbranch
