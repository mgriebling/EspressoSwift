// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CLib

public final class Espresso {
	
	/// Output returned by Espresso after an `init`.
	public private(set) var results: String = ""
	
	/**
	 Espresso is a program for boolean minimization. It takes as input
	 a two-level representation of a two-valued (or multiple-valued)
	 Boolean function, and produces a minimal equivalent representation.
	 
	 Here is a sample input file, whose name is passed as the last argument
	 (e.g., "-o", "eqntott", "filename"). The "-o eqntott" outputs
	 a relatively human-readable solution.  Leaving this argument off,
	 produces more of a machine-readable output.
	 
	 ```
	 .i 4        		# .i specifies the number of inputs
	 .o 3       		# .o specifies the number of outputs
	 .ilb Q1 Q0 D N 	# This line specifies the names of the inputs in order
	 .ob T1 T0 OPEN   	# This line specifies the names of the outputs in order
	 0011 ---      	# The first four digits (before the space) correspond
	 0101 110    		# to the inputs, the three after the space correspond
	 0110 100    		# to the outputs, both in order specified above.
	 0001 010
	 0010 100
	 0111 ---
	 1001 010
	 1010 010
	 1011 ---
	 1100 001
	 1101 001
	 1110 001
	 1111 ---
	 .e       # Signifies the end of the file.
	 ```
	 */
	public init(_ args: [String]) throws {
		// Create [UnsafeMutablePointer<Int8>]:
		let filename = "outputs.txt"
		var args = args; args.insert("Espresso", at: 0)
		var cargs = args.map { strdup($0) }
		
		// Call C function:
		let _ = top(Int32(args.count), &cargs, filename)
		results = try String(contentsOfFile: filename, encoding: .utf8)
		try? FileManager.default.removeItem(atPath: filename) // erase file
		
		defer {
			// Free the duplicated strings:
			for ptr in cargs { free(ptr) }
		}
	}
	
	/// On-the-fly Espresso initializer that takes a set of input/output
	/// names, number of inputs and outputs, and a set of input/output
	/// vectors.
	///
	/// The `inputNames`and `outputNames` can be arrays of arbitrary strings.
	/// However, the number of `inputNames` must match the `numberOfInputs` and
	/// the number of `outputNames` must match the `numberOfOutputs`. The
	/// `inputNames` and `outputNames` could be left empty.
	///
	/// The expected `vectors` format is (with four inputs and three outputs):
	///
	/// ```
	/// 0011 ---
	/// 0101 110
	/// 0110 100
	/// ```
	///
	/// where the first four digits (before the space) correspond to the
	/// inputs, the three after the space correspond to the outputs, both
	/// in the order specified above.
	///
	public convenience init? (
		_ inputNames: [String] = [], _ outputNames: [String] = [],
		_ numberOfInputs: Int, _ numberOfOutputs: Int,
		_ vectors: [String]) {
			// produce a dummy input file to feed to Espresso
			let filename = "DummyInputFile.txt"
			var fileContent = ".i \(numberOfInputs)\n.o \(numberOfOutputs)"
			
			// add input names to the file
			if inputNames.count > 0 {
				guard inputNames.count == numberOfInputs else { return nil }
				fileContent.append(".ilb")
				for name in inputNames {
					fileContent.append(" \(name)")
				}
				fileContent.append("\n")
			}
			
			// add output names to the file
			if outputNames.count > 0 {
				guard outputNames.count == numberOfOutputs else { return nil }
				fileContent.append(".ob")
				for name in outputNames {
					fileContent.append(" \(name)")
				}
				fileContent.append("\n")
			}
			
			// add the in/out vectors to the file
			guard vectors.count > 0 else { return nil }
			for vector in vectors {
				fileContent.append("\(vector)\n")
			}
			fileContent.append(".e\n")
			
			do {
				try fileContent.write(toFile: filename, atomically: true, encoding: .ascii)
				try self.init(["-o", "eqntott", filename])
				try FileManager.default.removeItem(atPath: filename) // erase file
			} catch {
				print("Error attempting to produce input file or running Espresso: \(error)")
				return nil
			}
		}
}
