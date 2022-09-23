#! /bin/bash
set -e

# package conf
package=ira
IDENTATION="> "

# user conf
ANDROIDTARGET=253de0e80504

# vars
CLEANBUILD=false
FAST=false
LIVERELOAD=""
IONICRUNNOBUILD=""

while getopts 'hcfnlt:' OPTION; do
  case "$OPTION" in
    h)
      echo "------- $package - ionic run android, simplified -------"
      echo " "
      echo "$package [options] [arguments]"
      echo " "
      echo "options:"
      echo "-h,            show brief help"
      echo "-c,            perform a clean build"
      echo "-f,            fast run - just execute ionic capacitor run"
      echo "-n,            --no-build at ionic capacitor run"
      echo "-l,            activate livereload"
      echo "-t <targetID>, specify target device - default is" $ANDROIDTARGET
      exit 0
      ;;
    c)
      export CLEANBUILD=true
      ;;
    f)
      export FAST=true
      ;;
    n)
      export IONICRUNNOBUILD="--no-build"
      ;;
    l)
      export LIVERELOAD="-l --external"
      ;;
    t)
        export ANDROIDTARGET=$OPTARG
      ;;
    ?)
      echo $IDENTATION"invalid $package option: "$1
      echo $IDENTATION"To see a brief help, run:"
      echo $IDENTATION$package -h
      exit 0
      ;;
  esac
done
shift "$(($OPTIND -1))"

echo $IDENTATION"$package target:    "$(pwd)
echo $IDENTATION"target device: "$ANDROIDTARGET
echo " "

if ! $FAST || [ ! -d "./android" ] || [ ! -d "./build" ]; then
    # no -c provided, but no build conf available
    if ! $CLEANBUILD && [ ! -d "./android" ] ; then
        echo $IDENTATION"No build configuration could be found. Performing a clean build ..."
        CLEANBUILD=true
    fi

    if [ -d "./build" ] ; then
        echo $IDENTATION"Removing builds folder" && rm -rf build
    fi

    if $CLEANBUILD && [ -d "./android" ] ; then
        echo $IDENTATION"Removing android folder" && rm -rf android
    fi

    echo $IDENTATION"Ionic Build" && ionic build

    if $CLEANBUILD ; then
        echo $IDENTATION"Adding android platform" && ionic cap add android
    fi

    echo $IDENTATION"Cap copy" && ionic cap copy
    echo $IDENTATION"Cap sync" && ionic cap sync
fi

echo $IDENTATION"Deploying" && ionic cap run android $IONICRUNNOBUILD $LIVERELOAD --target=$ANDROIDTARGET

echo " "
echo $IDENTATION"$package exited successfully"
exit 0