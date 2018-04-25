KBD_LOADKEYS=${KBD_LOADKEYS:-$(which loadkeys)}
KBD_DUMPKEYS=${KBD_DUMPKEYS:-$(which dumpkeys)}

upload_loadkeys() {
    upload "$KBD_LOADKEYS" /usr/bin/loadkeys
}

upload_dumpkeys() {
    upload "$KBD_DUMPKEYS" /usr/bin/dumpkeys
}

upload_loadkeys
upload_dumpkeys
