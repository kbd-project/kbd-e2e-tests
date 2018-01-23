# Variables:
#
#     KBD_SETFONT       Path to the setfont binary.
#     KBD_DATA
#     KBD_TESTS
#
#     KBD_TMP_DIR
#     KBD_VM_DIR
#
#     KBD_RECORD        Update the reference results.
#     KBD_RANDOMIZE     Run tests in random order.

KBD_SETFONT=${KBD_SETFONT:-$(which setfont)}
KBD_DATA=./data
KBD_TESTS=./tests

KBD_TMP_DIR=

cleanup() {
    trap - EXIT
    if [ -n "${KBD_VM_DIR-}" ]; then
        livm stop "$KBD_VM_DIR"
    fi
    if [ -n "$KBD_TMP_DIR" ]; then
        rm -rf "$KBD_TMP_DIR"
    fi
    exit "$1"
}

init() {
    trap 'cleanup $?' EXIT
    trap 'cleanup 1' HUP PIPE INT QUIT TERM
    if [ -z "${KBD_VM_DIR-}" ]; then
        KBD_TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/kbd-vm.XXXXXXXX")
        KBD_VM_DIR="$KBD_TMP_DIR/vm"
    fi
    LIVM_VGA=0x301 livm start "$KBD_VM_DIR"
}

run() {
    livm ssh "$KBD_VM_DIR" "$@"
}

upload() {
    livm scpto "$KBD_VM_DIR" -q "$@"
}

upload_setfont() {
    upload "$KBD_SETFONT" /usr/bin/setfont
}

upload_data() {
    upload -r "$KBD_DATA" data
}

# status {OK,FAIL,REC} {message}
status() {
    printf "%-04s %s\n" "$1" "$2"
}

run_test() {
    local name="$1" callback="$2"
    KBD_TEST_SUITE="$name"
    echo "==== $KBD_TEST_SUITE"
    run "rm -rf ./testdata"
    upload -r "$KBD_TESTS/$KBD_TEST_SUITE/testdata" "./testdata"
    $callback
}

run_tests() {
    local pattern="$1" callback="$2" t
    if [ -n "${KBD_RANDOMIZE-}" ]; then
        printf "%s\n" "$KBD_TESTS/"$pattern | sort -R | while read -r t; do
            run_test "${t#$KBD_TESTS/}" "$callback" </dev/null
        done
    else
        for t in "$KBD_TESTS/"$pattern; do
            run_test "${t#$KBD_TESTS/}" "$callback"
        done
    fi
}

file() {
    local name="file $1" target="$KBD_TESTS/$KBD_TEST_SUITE/output/$1"
    livm ssh "$KBD_VM_DIR" "cat $1" >"$KBD_TMP_DIR/file"
    if [ -n "${KBD_RECORD-}" ]; then
        status REC "$name"
        mkdir -p "$(dirname "$target")"
        mv "$KBD_TMP_DIR/file" "$target"
    else
        cmp "$KBD_TMP_DIR/file" "$target" || {
            status FAIL "$name"
            sleep 2
            false
        }
        status OK "$name"
    fi
}

screenshot() {
    local name="screenshot $1" target="$KBD_TESTS/$KBD_TEST_SUITE/output/$1.ppm"
    livm screenshot "$KBD_VM_DIR" "$KBD_TMP_DIR/screenshot.ppm" >/dev/null
    if [ -n "${KBD_RECORD-}" ]; then
        status REC "$name"
        mkdir -p "$(dirname "$target")"
        mv "$KBD_TMP_DIR/screenshot.ppm" "$target"
    else
        cmp "$KBD_TMP_DIR/screenshot.ppm" "$target" || {
            status FAIL "$name"
            open "$KBD_TMP_DIR/screenshot.ppm"
            open "$target"
            sleep 2
            false
        }
        status OK "$name"
    fi
}

init
upload_setfont
upload_data
