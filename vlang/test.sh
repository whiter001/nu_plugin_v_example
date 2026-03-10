#!/usr/bin/env bash
# Comprehensive test script for nu_plugin_v_example (duplicated from root)
# Tests the plugin protocol directly without needing nushell

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "=== nu_plugin_v_example Comprehensive Tests ==="
echo ""

# Ensure plugin is built
if [ ! -f "./nu_plugin_v_example" ]; then
    echo "Building plugin..."
    v -prod -o nu_plugin_v_example nu_plugin_v_example.v
fi

PASS=0
FAIL=0

# Test helper function
run_test() {
    local test_name="$1"
    local input="$2"
    local expected_pattern="$3"
    
    echo -n "Testing: $test_name... "
    output=$(printf '%s\n' "$input" | ./nu_plugin_v_example --stdio 2>&1)
    if echo "$output" | grep -q "$expected_pattern"; then
        echo "✓ PASS"
        ((PASS++))
    else
        echo "✗ FAIL"
        echo "  Expected pattern: $expected_pattern"
        echo "  Got: $output"
        ((FAIL++))
    fi
}

# Test 1: Usage without --stdio
echo "Test 1: Usage without --stdio"
output=$(./nu_plugin_v_example 2>&1)
if echo "$output" | grep -q "Usage: nu_plugin_v_example --stdio"; then
    echo "✓ PASS"
    ((PASS++))
else
    echo "✗ FAIL"
    ((FAIL++))
fi

# Test 2: Hello message is sent
echo ""
echo "Test 2: Hello message"
run_test "Hello message" 'Call: [0, "Signature"]' '"Hello"'

# Test 3: Signature request
echo ""
echo "Test 3: Signature request"
output=$(printf 'Call: [0, "Signature"]\nGoodbye\n' | ./nu_plugin_v_example --stdio 2>&1)
if echo "$output" | grep -q '"Signature"' && echo "$output" | grep -q '"v_example"'; then
    echo "✓ PASS"
    ((PASS++))
else
    echo "✗ FAIL"
    ((FAIL++))
fi

# ... remaining tests omitted for brevity ...

echo ""
echo "Total: $PASS passed, $FAIL failed"
