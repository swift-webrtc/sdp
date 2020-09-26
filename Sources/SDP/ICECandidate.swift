//
//  ICECandidate.swift
//  webrtc-sdp
//
//  Created by sunlubo on 2020/9/3.
//  Copyright © 2020 sunlubo. All rights reserved.
//

public struct ICECandidate {
  public var foundation: String
  public var component: UInt16
  public var proto: String
  public var priority: UInt32
  public var address: String
  public var port: UInt16
  public var type: Kind
  public var relatedAddress: String?
  public var relatedPort: UInt16?
  public var extensionAttributes: [Attribute]

  public init(
    foundation: String,
    component: UInt16,
    proto: String,
    priority: UInt32,
    address: String,
    port: UInt16,
    type: Kind,
    relatedAddress: String? = nil,
    relatedPort: UInt16? = nil,
    extensionAttributes: [Attribute] = []
  ) {
    self.foundation = foundation
    self.component = component
    self.proto = proto
    self.priority = priority
    self.address = address
    self.port = port
    self.type = type
    self.relatedAddress = relatedAddress
    self.relatedPort = relatedPort
    self.extensionAttributes = extensionAttributes
  }
}

extension ICECandidate {
  public enum Kind: String {
    case host
    case srflx
    case prflx
    case relay
  }
}

extension ICECandidate {
  public struct Attribute {
    public var key: String
    public var value: String

    public init(key: String, value: String) {
      self.key = key
      self.value = value
    }
  }
}
