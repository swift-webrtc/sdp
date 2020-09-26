//
//  LinuxMain.swift
//  webrtc-sdp
//
//  Created by sunlubo on 2020/9/3.
//  Copyright © 2020 sunlubo. All rights reserved.
//

import SDPTests
import XCTest

var tests = [XCTestCaseEntry]()
tests += SessionDescriptionTests.allTests()
tests += ICECandidateTests.allTests()
tests += ExtMapTests.allTests()
XCTMain(tests)
