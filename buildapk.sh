#!/bin/bash
#=========================================================
# path condition:
#      AndroidManifest.xml
#      java
#      res
#
# path output:
#      gen
#      bin
# 
# Usage:
#      buildapk.sh -p ${project_path} -n ${apk_name}
#
# Sample:
#      buildapk.sh project/Hello Hello
#
# Finally:
#      generate the ${apk_name} in ${project_path}
# 
#=========================================================


storepass=teststorepass
keypass=teststorepass

while getopts "p:n:s:k:h" arg
do
    case $arg in
        s)
        storepass=$OPTARG
        ;;

        k)
        keypass=$OPTARG
        ;;

        p)
        target_path=$OPTARG
        ;;

        n)
        target_apk=$OPTARG
        ;;

        h)
        echo "Usage: buildapk.sh -p project_path -n apk_name [options]"
        echo "options:"
        echo "-s   storepass"
        echo "-k   keypass"
        exit 0
        ;;

    esac
done


#if [ $# -le 1 ]; then
#    echo "Error: wrong number of arguments in cmd: $0 $* "
#    echo "Usage: buildapk.sh project_path apk_name [options]"
#    exit 1
#fi
if [ "x$target_path" == x ] ; then
  echo "No project path !"
  exit 1
fi

if [ "x$target_apk" == x ] ; then
  echo "No apk name !"
  exit 1
fi

echo "$PWD"
# please set sdk_home
if test -z $SDK_HOME; then
    echo "Error: no set SDK_HOME"
    exit 1
fi
sdk_home=$SDK_HOME

# init
if [[ ".apk" != "$target_apk" ]]; then
    echo "append suffix .apk"
    target_apk="$target_apk.apk"
fi
target_sdk_ver="android-24"
target_sdk_path=$sdk_home/platforms/$target_sdk_ver
target_sdk=$target_sdk_path/android.jar
AAPT=$sdk_home/build-tools/23.0.2/aapt
DX=$sdk_home/build-tools/23.0.2/dx
APKBUILDER=$sdk_home/tools/apkbuilder

if [ ! -d $target_path ]; then
    echo "Error: no such file: $target_path"
    exit 1
fi

cd $target_path

if [ ! -r AndroidManifest.xml ]; then
    echo "Error: no such file AndroidManifest.xml in $target_path"
    exit 1
fi

if [ ! -d res ]; then
    echo "Error: no such dir res in $target_path"
    exit 1
fi

if [ ! -d java ]; then
    echo "Error: no such dir java in $target_path"
    exit 1
fi

if [ -d bin ]; then
    rm -rf bin
fi
if [ -d gen ]; then
    rm -rf gen
fi
mkdir -p bin
mkdir -p gen

#step 1
$AAPT package -fm -J gen -S res -M AndroidManifest.xml -I $target_sdk

#step 2
# aidl file


#step 3
#find -name "*.java" -and -not -name ".*" > sources.list
echo ""
echo "javac java file to class file"
if [ -d $PWD/libs ]; then
  libs=$(ls $PWD/libs/*.jar)
  libs=$(echo -n $libs | sed -e "s/ /:/g")
  javac -encoding utf-8 -target 1.6 -source 1.6 -d bin -bootclasspath $target_sdk:$libs $(find ./java ./gen -name "*.java" -and -not -name ".*")
else
  javac -encoding utf-8 -target 1.6 -source 1.6 -d bin -bootclasspath $target_sdk $(find ./java ./gen -name "*.java" -and -not -name ".*")
fi
if [ $? == 0 ] ; then
  echo "javac OK !"
else
  echo "javac error !"
  exit 1
fi

#step 4
echo ""
echo "start dx classes.dex"
$DX --dex --output=./bin/classes.dex ./bin/
if [ $? == 0 ] ; then
  echo "dx classes.dex OK !"
else
  echo "dx classes.dex error !"
  exit 1
fi

#step 5
echo ""
echo "Start package resources"
$AAPT package -f -S res -M AndroidManifest.xml -I $target_sdk -F ./bin/resources.ap_
if [ $? == 0 ] ; then
  echo "package resources OK !"
else
  echo "package resources error !"
  exit 1
fi

#step 6
echo ""
echo "start build apk"
$APKBUILDER ./bin/$target_apk -u -z ./bin/resources.ap_ -f ./bin/classes.dex -rf ./java/
if [ $? == 0 ] ; then
  echo "build apk OK !"
else
  echo "build apk error !"
  exit 1
fi

#step 7
#**************************************************
#keytool -genkey -alias android.keystore -keyalg RSA -validity 100000 -keystore android.keystore
echo ""
echo "start sign a test key"
#export storepass=teststorepass
#export keypass=testkeypass
export keystore=/etc/keystore/test.keystore
if ! test -f "$keystore"; then
    echo "$keystore not found !"
    exit 1
fi
export alias_name="test"
jarsigner -keystore $keystore -storepass $storepass -keypass $keypass -signedjar ./bin/signed_$target_apk ./bin/$target_apk $alias_name
if [ $? == 0 ] ; then
  echo "sign apk OK !"
else
  echo "sign apk error !"
  exit 1
fi
#**************************************************

#step 8
echo "zipalign"
zipalign -v 4 ./bin/signed_$target_apk ./bin/final_signed_$target_apk
if [ $? == 0 ] ; then
  echo "========================================================="
  echo ""
  echo "Installed: $PWD/bin/final_signed_$target_apk"
  echo ""
  echo "========================================================="
  echo "finish!"
  exit 0
else
  echo "zipalign error !"
  exit 1
fi

