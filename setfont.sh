#!/bin/sh
set -eu
. "$(dirname "$0")/lib/init.sh"
. "$(dirname "$0")/lib/setfont.sh"

test_setfont() {
    run "
        set -e; export LANG=C
        clear >/dev/tty0
        setfont -16 -m ./data/setfont/trivial.trans -u ./data/setfont/def.uni ./data/setfont/default8x16.psfu >/dev/tty0
        printf '\033[?25l' >/dev/tty0  # hide cursor
    "

    run "
        exec >/dev/tty0; set -e; export LANG=C
        setfont ./testdata/font
        printf '\033%%@'  # return to ISO/IEC 2022
        for i in 2 3 4 5 6 7 8 9 A B C D E F; do
            printf '%sx ' \"\$i\"
            for j in 0 1 2 3 4 5 6 7 8 9 A B C D E F; do
                printf \"\\x\$i\$j\"
            done
            printf '\n'
        done
    "
    screenshot plain

    run "
        exec >/dev/tty0; set -e; export LANG=C
        clear
        printf '\033%%G'  # UTF-8
        printf 'Solar System\n'
        printf 'Солнечная система\n'
        printf 'Sluneční soustava\n'
        printf 'Ηλιακό σύστημα\n'
        printf 'የፀሐይ ሥርዓተ ፈለክ\n'
    "
    screenshot unicode

    # -o  <filename>  Write current font to <filename>
    run "
        exec >/dev/tty0; set -e; export LANG=C
        setfont -o font.psf
    "
    file font.psf

    # -O  <filename>  Write current font and unicode map to <filename>
    run "
        exec >/dev/tty0; set -e; export LANG=C
        setfont -O font.psfu
    "
    file font.psfu

    # -ou <filename>  Write current unicodemap to <filename>
    run "
        exec >/dev/tty0; set -e; export LANG=C
        setfont -ou font.uni
    "
    file font.uni
}

run_tests "setfont/*" test_setfont

test_setfont_trans() {
    run "
        set -e; export LANG=C
        clear >/dev/tty0
        setfont -16 -m ./data/setfont/trivial.trans -u ./data/setfont/def.uni ./data/setfont/default8x16.psfu >/dev/tty0
        printf '\033[?25l' >/dev/tty0  # hide cursor
        printf '\033%%@' >/dev/tty0  # return to ISO/IEC 2022
    "

    # -om <filename>  Write current consolemap to <filename>
    run "
        exec >/dev/tty0; set -e; export LANG=C
        setfont -om trivial.trans
    "
    file trivial.trans

    run "
        exec >/dev/tty0; set -e; export LANG=C
        setfont ./testdata/koi8r-8x16
        printf '\xc2\xee\xef\xf0\xee\xf1\n'
    "
    screenshot bnopnya

    run "
        exec >/dev/tty0; set -e; export LANG=C
        setfont -m ./testdata/cp1251_to_koi8-r.trans
        printf '\xc2\xee\xef\xf0\xee\xf1\n'
    "
    screenshot vopros
}

run_test "setfont_trans" test_setfont_trans
