#!/usr/bin/env nu
# Test script for nu_plugin_v_example using stdio protocol (duplicated)

let plugin_path = "./nu_plugin_v_example"

print "=== nu_plugin_v_example Protocol Test ==="
print $"Testing plugin at: ($plugin_path)"
print ""

# Test helper function - runs plugin as external command
def run_plugin [input: string] {
    printf $"%s\n" $input | ^./nu_plugin_v_example --stdio
}

# Test 1: Hello message (protocol handshake)
print "Test 1: Hello message (protocol handshake)"
let hello_result = run_plugin "hello"
if $hello_result =~ "nu-plugin" {
    print "✓ PASS - Protocol version received"
} else {
    print "✗ FAIL - No protocol response"
    exit 1
}

# Test 2: Signature request (command definition)
print ""
print "Test 2: Signature request (command definition)"
let sig_result = run_plugin 'Call: [0, "Signature"]\nGoodbye'
if $sig_result =~ "v_example" and $sig_result =~ "required_positional" {
    print "✓ PASS - Command signature received"
} else {
    print "✗ FAIL - No signature response"
    exit 1
}

# ... further tests abbreviated ...

print ""
print "=== All tests passed! ==="
print "The plugin protocol is working correctly."
