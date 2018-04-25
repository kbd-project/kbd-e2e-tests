KBD_SETFONT=${KBD_SETFONT:-$(which setfont)}

upload_setfont() {
    upload "$KBD_SETFONT" /usr/bin/setfont
}

upload_data_setfont() {
    run "mkdir -p ./data"
    upload -r "$KBD_DATA/setfont" data/setfont
}

upload_setfont
upload_data_setfont
