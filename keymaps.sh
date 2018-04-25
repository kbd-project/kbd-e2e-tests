#!/bin/sh
set -eu
. "$(dirname "$0")/lib/init.sh"
. "$(dirname "$0")/lib/keymaps.sh"

test_dump_and_load() {
    run "
        set -e; export LANG=C
        clear >/dev/tty0
        dumpkeys | loadkeys
    "
}

test_dump_and_load
