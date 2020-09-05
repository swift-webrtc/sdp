import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(SessionDescriptionTests.allTests),
    testCase(ICECandidateTests.allTests),
    testCase(ExtMapTests.allTests),
  ]
}
#endif
