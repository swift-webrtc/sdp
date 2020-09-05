//
//  SDPError.swift
//  sdp
//
//  Created by sunlubo on 2020/9/3.
//  Copyright © 2020 sunlubo. All rights reserved.
//

public struct SDPError: Error {
  public var line: Int
  public var message: String

  init(line: Int, message: String) {
    self.line = line
    self.message = message
  }
}
