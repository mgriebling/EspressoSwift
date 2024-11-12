// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CLib

public struct Espresso {
	
	/// Output returned by Espresso after an `init`.
	public private(set) var results: String = ""
	
	/// Various options that may be used with Espresso.
	/// Note: Not all options are provided and not all combinations
	/// make sense.
	public struct EspressoOptions: OptionSet {
		public let rawValue: Int
		
		/// Readable outputs -o eqntott
		public static let useNames = EspressoOptions(rawValue: 1 << 0)
		
		/// Provide statistics on function size -Dstats
		public static let exact    = EspressoOptions(rawValue: 1 << 1)
		
		/// Provide statistics on function size -Dstats
		public static let stats    = EspressoOptions(rawValue: 1 << 3)
		
		/// Provide short execution summary -s
		public static let short    = EspressoOptions(rawValue: 1 << 5)
		
		/// Provide longer execution summary -t
		public static let trace    = EspressoOptions(rawValue: 1 << 6)
		
		/// Output the ON-set (default) -of
		public static let onset    = EspressoOptions(rawValue: 1 << 7)
		
		/// Output the OFF-set (default) -or
		public static let offset   = EspressoOptions(rawValue: 1 << 8)
		
		/// Output the DC-set (default) -od
		public static let dcset    = EspressoOptions(rawValue: 1 << 9)
		
		public static let none : EspressoOptions = []
		public static let `default` = useNames
		public static let sets : EspressoOptions = [.onset, .offset, .dcset]
		
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}
	
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
	public init? (numberOfInputs: Int = 0, numberOfOutputs: Int = 0,
				  inputNames: [String] = [], outputNames: [String] = [],
				  vectors: [String], options: EspressoOptions = .default) {
		// produce a dummy input file to feed to Espresso
		let filename = "DummyInputFile.txt"
		
		let inputs = max(numberOfInputs, inputNames.count)
		let outputs = max(numberOfOutputs, outputNames.count)
		guard inputs > 0, outputs > 0 else { return nil }
		
		var fileContent = ".i \(inputs)\n.o \(outputs)\n"
		
		// add input names to the file
		if !inputNames.isEmpty {
			fileContent.append(".ilb ")
			fileContent.append(inputNames.joined(separator: " "))
			fileContent.append("\n")
		}
		
		// add output names to the file
		if !outputNames.isEmpty {
			fileContent.append(".ob ")
			fileContent.append(outputNames.joined(separator: " "))
			fileContent.append("\n")
		}
		
		// add the in/out vectors to the file
		guard !vectors.isEmpty else { return nil }
		fileContent.append(vectors.joined(separator: "\n"))
		fileContent.append(".e\n")
		
		// Supported program options
		let useNames = options.contains(.useNames) ? ["-o", "eqntott"] : []
		let stats = options.contains(.stats) ? ["-Dstats"] : []
		let costs = options.contains(.short) ? ["-s"] : []
		let trace = options.contains(.trace) ? ["-t"] : []
		let exact = options.contains(.exact) ? ["-Dexact"] : []
		
		// following options are merged together
		let onset = options.contains(.onset) ? "f" : ""
		let offset = options.contains(.offset) ? "r" : ""
		let dcset = options.contains(.dcset) ? "d" : ""
		let onoffdcset = options.intersection(.sets).isEmpty ? [] : ["-o"+onset+offset+dcset]
		
		do {
			try fileContent.write(toFile: filename, atomically: true, encoding: .ascii)
			let options = useNames + stats + costs + trace + onoffdcset + exact
			try self.init(options + [filename])
			try FileManager.default.removeItem(atPath: filename) // erase file
		} catch {
			print("Error attempting to produce input file or running Espresso: \(error)")
			return nil
		}
	}
	
	/// initialization with no names
	public init?(	_ numberOfInputs: Int, _ numberOfOutputs: Int, _ vectors: [String], _ options: EspressoOptions = .default) {
		self.init(numberOfInputs: numberOfInputs, numberOfOutputs: numberOfOutputs, vectors: vectors, options: options)
	}
	
	/// initialization with names
	public init?(_ inputNames: [String], _ outputNames: [String], _ vectors: [String], _ options: EspressoOptions = .default) {
		self.init(inputNames: inputNames, outputNames: outputNames, vectors: vectors, options: options)
	}
}
