import SDPTests
import XCTest

var tests = [XCTestCaseEntry]()
tests += SessionDescriptionTests.allTests()
tests += ICECandidateTests.allTests()
tests += ExtMapTests.allTests()
XCTMain(tests)
