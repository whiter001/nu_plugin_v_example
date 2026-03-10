#!/usr/bin/env nu

# Test script for nu_plugin_v_example
# Reference: https://github.com/nushell/plugin-examples/blob/main/javascript/nu_plugin_node_example/test_nu_plugin_node_example.nu

use std/testing *
use std/assert

@test
def "test basic output" [] {
    # Expected output: 10 rows with columns one, two, three
    let expected = (0..9 | generate {|i| {out: {one: $i, two: ($i * 2), three: ($i * 3)}, next: ($i + 1)}} 0)
    assert equal (v_example 1 a) $expected
}

@test
def "test output length" [] {
    # Should return exactly 10 rows
    assert equal (v_example 1 a | length) 10
}

@test
def "test required parameters" [] {
    # Test with required parameters a (int) and b (string)
    let result = v_example 42 "hello"
    assert equal ($result | length) 10
    assert equal ($result | get one | first) 0
    assert equal ($result | get three | last) 27
}

@test
def "test with optional parameter" [] {
    # Test with optional parameter opt
    let result = v_example 10 "test" 5
    assert equal ($result | length) 10
}

@test
def "test with rest parameters" [] {
    # Test with rest parameters
    let result = v_example 7 "demo" 3 a b c
    assert equal ($result | length) 10
}

@test
def "test with named flags" [] {
    # Test with --flag
    let result = v_example 100 "flags" --flag
    assert equal ($result | length) 10
}
