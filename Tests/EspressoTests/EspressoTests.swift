import XCTest
@testable import CLib

//func withArrayOfCString<R>(_ args: [String], _ body: ([UnsafeMutablePointer<CChar>?]) -> R) -> R {
//	var cStrings = args.map { strdup($0) }
//	cStrings.append(nil)
//	defer {
//		cStrings.forEach { free($0) }
//	}
//	return body(cStrings)
//}
//
//func mainy(_ args: inout String) {
//	UnsafeMutablePointer<CChar>? = withArrayOfCString(args) { unsafeArgs in
//		var message = unsafeArgs
//		CLib.main(3, &message)
//	}
////	CLib.main(3, &message)
////	args = "Hi there"
//	
//}

final class EspressoTests: XCTestCase {
	
    func testExample() throws {
		// temporary file to log the Espresso outputs
		let filename = "outputs.txt"
		
		// substitute your own test input file here
		// Note: this only seems to work during tests otherwise you
		// need to put the file in a directory accessible to your App
		var args = ["/Users/mikeg/Work/Tests/espresso-logic-master/examples/dekoder.txt"]
		args.insert("Espresso", at: 0)
		
		// transform to C-style strings in an array
		var cargs = args.map { strdup($0) }
		
		// Call C function:
		let _ = top(Int32(args.count), &cargs, filename)
		let results = try String(contentsOfFile: filename, encoding: .utf8)
		print(results)
		try? FileManager.default.removeItem(atPath: filename) // erase file
		
		// Free the duplicated strings:
		for ptr in cargs { free(ptr) }
	}
		
}
