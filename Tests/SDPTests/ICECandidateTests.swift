//
//  ICECandidateTests.swift
//  webrtc-sdp
//
//  Created by sunlubo on 2020/9/5.
//  Copyright © 2020 sunlubo. All rights reserved.
//

import XCTest

@testable import SDP

final class ICECandidateTests: XCTestCase {
  let source = "1 1 UDP 9654321 212.223.223.223 12345 typ srflx raddr 10.216.33.9 rport 54321"

  func testDeserialize() throws {
    let candidate = try ICECandidate.deserialize(from: source)
    XCTAssertEqual(candidate.foundation, "1")
    XCTAssertEqual(candidate.component, 1)
    XCTAssertEqual(candidate.proto, "UDP")
    XCTAssertEqual(candidate.priority, 9_654_321)
    XCTAssertEqual(candidate.address, "212.223.223.223")
    XCTAssertEqual(candidate.port, 12345)
    XCTAssertEqual(candidate.type, .srflx)
    XCTAssertEqual(candidate.relatedAddress, "10.216.33.9")
    XCTAssertEqual(candidate.relatedPort, 54321)
    XCTAssertTrue(candidate.extensionAttributes.isEmpty)
  }

  func testSerialize() {
    let candidate = ICECandidate(
      foundation: "1",
      component: 1,
      proto: "UDP",
      priority: 9_654_321,
      address: "212.223.223.223",
      port: 12345,
      type: .srflx,
      relatedAddress: "10.216.33.9",
      relatedPort: 54321,
      extensionAttributes: []
    )
    XCTAssertEqual(candidate.serialize(), source)
  }

  static var allTests = [
    ("testDeserialize", testDeserialize),
    ("testSerialize", testSerialize),
  ]
}
