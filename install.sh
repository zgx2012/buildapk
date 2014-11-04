#!/bin/bash
test -z /usr/local/bin || mkdir -p /usr/local/bin
cp buildapk.sh /usr/local/bin/buildapk
echo "test -d /usr/local/bin || mkdir -p /usr/local/bin"
echo "cp buildapk.sh /usr/local/bin/buildapk"

test -z /etc/keystore || mkdir -p /etc/keystore
cp test.keystore /etc/keystore/
echo "test -d /etc/keystore || mkdir -p /etc/keystore"
echo "cp test.keystore /etc/keystore/"
