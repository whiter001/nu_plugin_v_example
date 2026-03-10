#!/usr/bin/env -S v run

import os

const plugin_name = 'v_example'
const plugin_desc = 'Demonstration plugin for V'

// Message types for the plugin protocol
struct Hello {
	protocol string
	version  string
	features []string
}

struct Signature {}

struct Metadata {}

struct CallInfo {
	call Call
}

struct Call {
	head      Head
	check     bool
	positional []Value
	named     map[string]Value
	rest      []Value
	redirected bool
}

struct Head {
	name   string
	span   Span
	inspector_id int
}

struct Span {
	start int
	end   int
}

struct Value {
	value ValueInner
}

struct ValueInner {
	int    int
	string string
	bool   bool
}

struct PipelineData {
	list List
}

struct List {
	items []ListItem
}

struct ListItem {
	value ListItemValue
}

struct ListItemValue {
	record Record
}

struct Record {
	cols []string
	vals []RecordValue
}

struct RecordValue {
	int int
}

struct PluginError {
	msg    string
	labels []Label
}

struct Label {
	span    Span
	text    string
	help    string
}

struct CallResponse {
	id    int
	data  ResponseData
}

struct ResponseData {
	pipeline_data PipelineData
	error         PluginError
}

struct PluginMessage {
	hello         Hello
	call          CallInfo
	call_response CallResponse
	goodbye       string
}

fn main() {
	args := os.args
	mut has_stdio := false
	for arg in args {
		if arg == '--stdio' {
			has_stdio = true
			break
		}
	}
	if has_stdio {
		run_plugin()
	} else {
		println('Usage: nu_plugin_v_example --stdio')
		println('This is a nushell plugin that should be run by nushell.')
	}
}

fn run_plugin() {
	mut f := os.stdout()
	// Tell nushell we are using JSON encoding
	f.write_string('\x04json\n') or {}
	f.flush()
	// Send Hello message
	send_raw('{"Hello":{"protocol":"nu-plugin","version":"0.111.0","features":[]}}')

	mut buf := []u8{cap: 4096}
	unsafe {
		mut fd_buf := [1]u8{}
		for {
			n := C.read(0, fd_buf, 1)
			if n <= 0 {
				break
			}
			b := fd_buf[0]
			if b == `\n` {
				line := buf.bytestr().trim_space()
				buf = buf[..0]
				if line.len == 0 {
					continue
				}
				// "Goodbye" is a JSON string literal in the stream
				if line == '"Goodbye"' {
					break
				}
				if line.contains('"Hello"') {
					// Already sent our Hello; just ignore theirs
					continue
				}
				if line.contains('"Call"') {
					dispatch_call(line)
				}
			} else {
				buf << b
			}
		}
	}
}

// Extract the numeric call-id from: {"Call":[<id>, ...]}
fn extract_call_id(line string) int {
	idx := line.index('"Call"') or { return 0 }
	bracket := line.index_after('[', idx) or { return 0 }
	mut i := bracket + 1
	for i < line.len && (line[i] == ` ` || line[i] == `\t`) {
		i++
	}
	mut num := ''
	for i < line.len && line[i] >= `0` && line[i] <= `9` {
		num += line[i..i + 1]
		i++
	}
	return if num.len > 0 { num.int() } else { 0 }
}

fn dispatch_call(line string) {
	id := extract_call_id(line)
	if line.contains('"Signature"') {
		send_signature(id)
	} else if line.contains('"Metadata"') {
		send_metadata(id)
	} else if line.contains('"Run"') {
		handle_run(id)
	}
}

fn send_signature(id int) {
	// Matches the format used in nu_plugin_nu_example.nu
	json := '{"CallResponse":[${id},{"Signature":[{"sig":{"name":"v_example","description":"Demonstration plugin written in V","extra_description":"","search_terms":["vlang","example"],"required_positional":[{"name":"a","desc":"required integer value","shape":"Int"},{"name":"b","desc":"required string value","shape":"String"}],"optional_positional":[],"rest_positional":null,"named":[],"input_output_types":[["Any","Any"]],"allow_variants_without_examples":true,"is_filter":false,"creates_scope":false,"allows_unknown_args":false,"category":"Experimental"},"examples":[]}]}]}'
	send_raw(json)
}

fn send_metadata(id int) {
	send_raw('{"CallResponse":[${id},{"Metadata":{"version":"0.1.0"}}]}')
}

fn handle_run(id int) {
	// Build a 10-row table: columns one, two, three
	// PipelineData format: {"Value": [<list_value>, null]}
	span := '{"start":0,"end":0}'
	mut vals := []string{}
	for i in 0 .. 10 {
		rec := '{"Record":{"val":{"one":{"Int":{"val":${i},"span":${span}}},"two":{"Int":{"val":${i * 2},"span":${span}}},"three":{"Int":{"val":${i * 3},"span":${span}}}},"span":${span}}}'
		vals << rec
	}
	list_val := '{"List":{"vals":[${vals.join(',')}],"span":${span}}}'
	json := '{"CallResponse":[${id},{"PipelineData":{"Value":[${list_val},null]}}]}'
	send_raw(json)
}

fn send_raw(json string) {
	mut f := os.stdout()
	f.write_string(json + '\n') or {}
	f.flush()
}
