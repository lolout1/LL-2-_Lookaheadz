#!/bin/bash
# run all scanner test cases and diff against expected output

PROGRAM="${1:-obj/scanner}"
TESTDIR="test/cases"
EXPDIR="test/exp"
PASSED=0
FAILED=0

for input in "$TESTDIR"/*.mC; do
    name=$(basename "$input" .mC)
    expected="$EXPDIR/$name.exp"

    if [ ! -f "$expected" ]; then
        echo "  SKIP  $name (no expected output)"
        continue
    fi

    actual=$(timeout 10 "$PROGRAM" "$input" 2>&1)
    expected_content=$(cat "$expected")

    if [ "$actual" = "$expected_content" ]; then
        echo "  PASS  $name"
        PASSED=$((PASSED + 1))
    else
        echo "  FAIL  $name"
        FAILED=$((FAILED + 1))
        diff <(echo "$actual") "$expected" | head -6
    fi
done

echo ""
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ]
