#!/bin/bash
set -eu

CONTEXT=$(mktemp)
RESULT=$(mktemp)
EXEC=${EXEC:-./contemplate}

OK="\e[32mOK  \e[0m"
FAIL="\e[31mFAIL\e[0m"

run()
{
    $EXEC test.tmpl $@ > $RESULT
}

assert()
{
    echo -n $1...
    test "$(<$RESULT)" = "$2" && echo -e $OK || echo -e "$FAIL: "$(<$RESULT)" != "$2""
}

run
assert "no context" "'' ''"

echo 'test: stdin' | run
assert "context from stdin" "'stdin' ''"

echo 'test: file' > $CONTEXT
run -c $CONTEXT
assert "context from file" "'file' ''"

TEST=envvar run
assert "context from envvar" "'' 'envvar'"

echo 'test: file' > $CONTEXT
echo 'test: stdin' | run -c $CONTEXT
assert "file overrides stdin" "'file' ''"

echo 'env: {TEST: file}' > $CONTEXT
TEST=envvar run -c $CONTEXT
assert "file overrides envvar" "'' 'file'"

echo 'env: {TEST: file}' | TEST=envvar run
assert "stdin overrides envvar" "'' 'file'"
