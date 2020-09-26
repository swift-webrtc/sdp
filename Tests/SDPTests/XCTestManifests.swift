//
//  XCTestManifests.swift
//  webrtc-sdp
//
//  Created by sunlubo on 2020/9/3.
//  Copyright © 2020 sunlubo. All rights reserved.
//

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
