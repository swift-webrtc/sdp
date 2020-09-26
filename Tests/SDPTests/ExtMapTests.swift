//
//  ExtMapTests.swift
//  webrtc-sdp
//
//  Created by sunlubo on 2020/9/5.
//  Copyright © 2020 sunlubo. All rights reserved.
//

@testable
import SDP
import XCTest

final class ExtMapTests: XCTestCase {
  let source = "1/sendrecv http://example.com/082005/ext.htm#xmeta short"

  func testDeserialize() throws {
    let extmap = try ExtMap.deserialize(from: source)
    XCTAssertEqual(extmap.value, 1)
    XCTAssertEqual(extmap.direction, .sendRecv)
    XCTAssertEqual(extmap.uri, "http://example.com/082005/ext.htm#xmeta")
    XCTAssertEqual(extmap.extensionAttributes, "short")
  }

  func testSerialize() {
    let extmap = ExtMap(
      value: 1,
      direction: .sendRecv,
      uri: "http://example.com/082005/ext.htm#xmeta",
      extensionAttributes: "short"
    )
    XCTAssertEqual(extmap.serialize(), source)
  }

  static var allTests = [
    ("testDeserialize", testDeserialize),
    ("testSerialize", testSerialize),
  ]
}
