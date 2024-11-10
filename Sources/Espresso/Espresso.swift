// The Swift Programming Language
// https://docs.swift.org/swift-book

import CLib

@main
public final class Espresso {

	public init(_ args: [String]) {
		let args = ["espresso", /* "-o", "eqntott",*/ "/Users/mikeg/Work/Tests/espresso-logic-master/examples/check2"]

		// Create [UnsafeMutablePointer<Int8>]:
		var cargs = args.map { strdup($0) }
		// Call C function:
		let _ = top(Int32(args.count), &cargs)
		// Free the duplicated strings:
		for ptr in cargs { free(ptr) }
	}
	
}
