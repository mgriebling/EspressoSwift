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
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
		let args = ["espresso", /* "-o", "eqntott",*/ "/Users/mikeg/Work/Tests/espresso-logic-master/examples/check2"]
		let file = "/Users/mikeg/Work/Tests/espresso-logic-master/examples/check2.txt"

		// Create [UnsafeMutablePointer<Int8>]:
		var cargs = args.map { strdup($0) }
		
		// Call C function:
		let _ = top(Int32(args.count), &cargs, file.cString(using: .ascii))
		let content = try String(contentsOfFile: file, encoding: .utf8)
		print(content)
		
		// Free the duplicated strings:
		for ptr in cargs { free(ptr) }
    }
		

}
