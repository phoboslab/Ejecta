#!/bin/bash

PROJECT_NAME=$1
ARG1=$2
#PROJECT_DIR=`dirname $0`/..
PROJECT_DIR=${PWD}/..
APP_DIR=${PROJECT_DIR}/App
echo ${PROJECT_DIR}
echo ${APP_DIR}
echo "==========================="

cd ~/DEV/www/${PROJECT_NAME}/


if [[ $(echo ${ARG1} | grep -o "all") != "" ]]
then
    echo "  Building js ..."
    node build.js
    echo "==========================="
fi


rm -rf ${APP_DIR}/res
cp -rf ./client/res  ${APP_DIR}/


cp -f ./client/all_in_one.js  ${APP_DIR}/all_in_one.js


mkdir ${APP_DIR}/marketing
mkdir ${APP_DIR}/boot
mkdir ${APP_DIR}/boot/native

if [[ $(echo ${PROJECT_DIR} | grep -o "Unlimited") != "" ]]
then
    cp -f ./client/marketing/share-unlimited.png  ${APP_DIR}/marketing/share.png
	cp -f ./client/marketing/icon-unlimited.png  ${APP_DIR}/marketing/icon.png
	cp -f ./client/boot/native/index-config-unlimited.js  ${APP_DIR}/boot/native/index-config.js
	echo "Unlimited"
else
    cp -f ./client/marketing/share.png  ${APP_DIR}/marketing/share.png
	cp -f ./client/marketing/icon.png  ${APP_DIR}/marketing/icon.png
	cp -f ./client/boot/native/index-config.js  ${APP_DIR}/boot/native/index-config.js
	echo "Limited"
fi

cp -f ./client/boot/native/ad-init.js  ${APP_DIR}/boot/native/ad-init.js
cp -f ./client/boot/native/index-init.js  ${APP_DIR}/boot/native/index-init.js
cp -f ./client/index.js  ${APP_DIR}/index.js


cd  ${PROJECT_DIR}/build-tool/
cp -f ../Tools/encrypt-files.js ./encrypt-files.js
node encrypt-files.js all
rm -f encrypt-files.js
read -n 1 -p "Press any key to finish..."