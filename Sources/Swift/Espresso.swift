// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CLib

public final class Espresso {
	
	var results: String = ""

	public init(_ args: [String], _ file: String) throws {
		// let args = ["espresso", /* "-o", "eqntott",*/ "/Users/mikeg/Work/Tests/espresso-logic-master/examples/check2"]
		// let file = "/Users/mikeg/Work/Tests/espresso-logic-master/examples/check2.txt"

		// Create [UnsafeMutablePointer<Int8>]:
		var cargs = args.map { strdup($0) }
		
		// Call C function:
		let _ = top(Int32(args.count), &cargs, file.cString(using: .ascii))
		results = try String(contentsOfFile: file, encoding: .utf8)
		
		// Free the duplicated strings:
		for ptr in cargs { free(ptr) }
	}
	
}
