#!/bin/sh
SCRIPT_FOLDER="$(cd "$(dirname $0)" && pwd)"
USERNAME=${1:-root}

if [ -z "$HOME" ]; then
    HOME="/root"
fi

FAILED=""

echoStderr()
{
    echo "$@" 1>&2
}

check() {
    LABEL=$1
    shift
    printf "\n"
    printf "🔄 Testing '%s'\n" "$LABEL"
    printf '\033[37m'
    if "$@"; then
        printf "\n" 
        printf "✅  Passed '%s'!\n" "$LABEL"
        return 0
    else
        printf "\n"
        echoStderr "❌ $LABEL check failed."
        if [ -z "$FAILED" ]; then
            FAILED="$LABEL"
        else
            FAILED="$FAILED $LABEL"
        fi
        return 1
    fi
}

checkMultiple() {
    PASSED=0
    LABEL="$1"
    printf "\n"
    printf "🔄 Testing '%s'.\n" "$LABEL"
    shift; MINIMUMPASSED=$1
    shift; EXPRESSION="$1"
    while [ "$EXPRESSION" != "" ]; do
        if $EXPRESSION; then 
            PASSED=$((PASSED + 1))
        fi
        shift; EXPRESSION=$1
    done
    if [ $PASSED -ge $MINIMUMPASSED ]; then
        printf "\n"
        printf "✅ Passed!\n"
        return 0
    else
        printf "\n"
        echoStderr "❌ '$LABEL' check failed."
        if [ -z "$FAILED" ]; then
            FAILED="$LABEL"
        else
            FAILED="$FAILED $LABEL"
        fi
        return 1
    fi
}

reportResults() {
    if [ -n "$FAILED" ]; then
        printf "\n"
        echoStderr "💥  Failed tests: $FAILED"
        exit 1
    else
        printf "\n"
        printf "Test Passed!\n"
        exit 0
    fi
}