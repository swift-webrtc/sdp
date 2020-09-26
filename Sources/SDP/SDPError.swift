//
//  SDPError.swift
//  webrtc-sdp
//
//  Created by sunlubo on 2020/9/3.
//  Copyright © 2020 sunlubo. All rights reserved.
//

public struct SDPError: Error {
  public var message: String

  public init(message: String) {
    self.message = message
  }
}
