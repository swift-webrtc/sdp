//
//  Attribute.swift
//  webrtc-sdp
//
//  Created by sunlubo on 2020/9/3.
//  Copyright © 2020 sunlubo. All rights reserved.
//

// http://www.iana.org/assignments/sdp-parameters/sdp-parameters.xhtml
extension SessionDescription.Attribute.Key {
  public static let candidate = Self(rawValue: "candidate")
  public static let extMap = Self(rawValue: "extmap")
  public static let fingerprint = Self(rawValue: "fingerprint")
  public static let fmtp = Self(rawValue: "fmtp")
  public static let group = Self(rawValue: "group")
  public static let iceLite = Self(rawValue: "ice-lite")
  public static let iceMismatch = Self(rawValue: "ice-mismatch")
  public static let iceOptions = Self(rawValue: "ice-options")
  public static let icePwd = Self(rawValue: "ice-pwd")
  public static let iceUfrag = Self(rawValue: "ice-ufrag")
  public static let inactive = Self(rawValue: "inactive")
  public static let maxMessageSize = Self(rawValue: "max-message-size")
  public static let mid = Self(rawValue: "mid")
  public static let msid = Self(rawValue: "msid")
  /// This is a legacy field supported only for Plan B semantics.
  ///
  /// [draft-alvestrand-mmusic-msid-02](https://tools.ietf.org/html/draft-alvestrand-mmusic-msid-02)
  public static let msidSemantic = Self(rawValue: "msid-semantic")
  public static let recvOnly = Self(rawValue: "recvonly")
  public static let rtcp = Self(rawValue: "rtcp")
  public static let rtcpFb = Self(rawValue: "rtcp-fb")
  public static let rtcpMux = Self(rawValue: "rtcp-mux")
  public static let rtcpRsize = Self(rawValue: "rtcp-rsize")
  public static let rtpMap = Self(rawValue: "rtpmap")
  public static let sctpPort = Self(rawValue: "sctp-port")
  public static let sendOnly = Self(rawValue: "sendonly")
  public static let sendRecv = Self(rawValue: "sendrecv")
  public static let setup = Self(rawValue: "setup")
  public static let ssrc = Self(rawValue: "ssrc")
  public static let ssrcGroup = Self(rawValue: "ssrc-group")
}
