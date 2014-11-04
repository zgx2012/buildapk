buildapk in Linux
========
Install:

    $ ./install.sh
    It will install buildapk and test.keystore.
    copy buildapk.sh to /usr/local/bin/
    copy test.keystore to /etc/keystore/

Usage:

    buildapk -p ${project_path} -n ${apk_name} [options]
    options:
    -s   storepass
    -k   keypass
    It will generate a signed and zipaligned apk.

Example:

    I have a Hello Android Project.
    $ cd Hello
    $ buildapk -p . -n hello -k testkeypass -s teststorepass
    Then, It will generate signed and zipaligned bin/final_signed_hello.apk.
    Besides, It will generate non-signed bin/hello.apk, signed bin/signed_hello.apk

