KBD_KBD_MODE=${KBD_KBD_MODE:-$(which kbd_mode)}
KBD_LOADKEYS=${KBD_LOADKEYS:-$(which loadkeys)}
KBD_DUMPKEYS=${KBD_DUMPKEYS:-$(which dumpkeys)}

upload_kbd_mode() {
    upload "$KBD_KBD_MODE" /usr/bin/kbd_mode
}

upload_loadkeys() {
    upload "$KBD_LOADKEYS" /usr/bin/loadkeys
}

upload_dumpkeys() {
    upload "$KBD_DUMPKEYS" /usr/bin/dumpkeys
}

upload_kbd_mode
upload_loadkeys
upload_dumpkeys
