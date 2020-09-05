//
//  OptionalExt.swift
//  sdp
//
//  Created by sunlubo on 2020/9/5.
//  Copyright © 2020 sunlubo. All rights reserved.
//

extension Optional {

  func unwrapped(or error: Error) throws -> Wrapped {
    guard let wrapped = self else {
      throw error
    }
    return wrapped
  }
}
