// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CLib

public final class Espresso {
	
	public private(set) var results: String = ""

	public init(_ args: [String]) throws {
		// let args = ["espresso", /* "-o", "eqntott",*/ "/Users/mikeg/Work/Tests/espresso-logic-master/examples/check2"]
		// let file = "/Users/mikeg/Work/Tests/espresso-logic-master/examples/check2.txt"

		// Create [UnsafeMutablePointer<Int8>]:
		var cargs = args.map { strdup($0) }
		
		// Call C function:
		let _ = top(Int32(args.count), &cargs, "outputs.txt")
		results = try String(contentsOfFile: "outputs.txt", encoding: .utf8)
		
		defer {
			// Free the duplicated strings:
			for ptr in cargs { free(ptr) }
		}
	}
	
}
