#!/bin/bash
set -eu

CONTEXT=$(mktemp)
ENVFILE=$(mktemp)
RESULT=$(mktemp)
EXEC=${EXEC:-./contemplate}

OK="\e[32mOK  \e[0m"
FAIL="\e[31mFAIL\e[0m"

run()
{
    $EXEC $@ > $RESULT
}

assert()
{
    echo -n $1...
    test "$(<$RESULT)" = "$2" && echo -e $OK || echo -e "$FAIL: "$(<$RESULT)" != "$2""
}

run test.tmpl
assert "no context" "'' ''"

echo 'test: stdin' | run test.tmpl
assert "context from stdin" "'stdin' ''"

echo 'test: file' > $CONTEXT
run test.tmpl -c $CONTEXT
assert "context from file" "'file' ''"

TEST=envvar run test.tmpl
assert "context from envvar" "'' 'envvar'"

echo 'TEST=envfile' > $ENVFILE
run test.tmpl -e $ENVFILE
assert "context from envfile" "'' 'envfile'"

echo 'test: file' > $CONTEXT
echo 'test: stdin' | run test.tmpl -c $CONTEXT
assert "file overrides stdin" "'file' ''"

echo 'TEST=envfile' > $ENVFILE
echo 'env: {TEST: file}' > $CONTEXT
TEST=envvar run test.tmpl -c $CONTEXT -e $ENVFILE
assert "file overrides envfile" "'' 'file'"

echo 'env: {TEST: file}' > $CONTEXT
TEST=envvar run test.tmpl -c $CONTEXT
assert "file overrides envvar" "'' 'file'"

echo 'TEST=envfile' > $ENVFILE
echo 'env: {TEST: stdin}' | run test.tmpl -e $ENVFILE
assert "stdin overrides envfile" "'' 'stdin'"

echo 'env: {TEST: file}' | TEST=envvar run test.tmpl
assert "stdin overrides envvar" "'' 'file'"

echo 'TEST=envfile' > $ENVFILE
TEST=envvar run test.tmpl -e $ENVFILE
assert "envvar overrides envvar" "'' 'envfile'"

