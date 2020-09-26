//
//  ExtMap.swift
//  webrtc-sdp
//
//  Created by sunlubo on 2020/9/5.
//  Copyright © 2020 sunlubo. All rights reserved.
//

/// ExtMap represents the activation of a single RTP header extension.
public struct ExtMap {
  public var value: Int
  public var direction: Direction?
  public var uri: URI
  public var extensionAttributes: String?

  public init(
    value: Int,
    direction: Direction? = nil,
    uri: URI,
    extensionAttributes: String? = nil
  ) {
    self.value = value
    self.direction = direction
    self.uri = uri
    self.extensionAttributes = extensionAttributes
  }
}

extension ExtMap {
  public enum Direction: String {
    case sendRecv = "sendrecv"
    case sendOnly = "sendonly"
    case recvOnly = "recvonly"
    case inactive = "inactive"
  }
}

extension ExtMap {
  public struct URI: Equatable, ExpressibleByStringLiteral {
    /// Header extension for absolute send time, see
    /// [abs-send-time](http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time) for details.
    public static let absSendTime = "http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time"
    /// Header extension for transport sequence number, see
    /// [draft-holmer-rmcat-transport-wide-cc-extensions](http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions) for details.
    public static let transportSequenceNumber =
      "http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01"
    /// Header extension for identifying media section within a transport, see
    /// [draft-ietf-mmusic-sdp-bundle-negotiation-49#section-15](https://tools.ietf.org/html/draft-ietf-mmusic-sdp-bundle-negotiation-49#section-15) for details.
    public static let mid = "urn:ietf:params:rtp-hdrext:sdes:mid"
    /// Header extension for RIDs, see
    /// [draft-ietf-avtext-rid-09](https://tools.ietf.org/html/draft-ietf-avtext-rid-09) for details.
    public static let rid = "urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id"
    /// Header extension for Repaired RIDs, see
    /// [draft-ietf-mmusic-rid-15](https://tools.ietf.org/html/draft-ietf-mmusic-rid-15) for details.
    public static let repairedRid =
      "urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id"

    var rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
      self.rawValue = value
    }
  }
}
