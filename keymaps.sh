#!/bin/sh
set -eu
. "$(dirname "$0")/lib/init.sh"
. "$(dirname "$0")/lib/keymaps.sh"

test_keymap() {
    run "
        set -e; export LANG=C
        cd ./testdata
        kbd_mode -C /dev/tty0 -u
        (printf 'keymaps 0\n'; seq 0 255 | sed -e 's/.*/keycode & =/') | loadkeys -c -s
        LOADKEYS_INCLUDE_PATH=. loadkeys -C /dev/tty0 ./keymap
        dumpkeys </dev/tty0 -f >../unicode.full.map
    "
    file unicode.full.map

    run "
        set -e; export LANG=C
        cd ./testdata

        if [ -e ./skip_ascii ]; then
            echo '# skip_ascii' >../ascii.full.map
            exit 0
        fi

        kbd_mode -C /dev/tty0 -a
        (printf 'keymaps 0\n'; seq 0 255 | sed -e 's/.*/keycode & =/') | loadkeys -c -s
        LOADKEYS_INCLUDE_PATH=. loadkeys -C /dev/tty0 ./keymap
        dumpkeys </dev/tty0 -f \$(sed -ne 's/^charset \"\\(.*\\)\"\\( *#.*\\)\\?$/-c \\1/p' ./keymap) >../ascii.full.map
    "
    file ascii.full.map
}

run_tests "keymaps/*" test_keymap
