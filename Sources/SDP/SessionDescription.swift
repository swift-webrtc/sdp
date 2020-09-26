//
//  SessionDescription.swift
//  webrtc-sdp
//
//  Created by sunlubo on 2020/9/3.
//  Copyright © 2020 sunlubo. All rights reserved.
//

/// SessionDescription is a a well-defined format for conveying sufficient
/// information to discover and participate in a multimedia session.
///
/// [RFC4566](https://tools.ietf.org/html/rfc4566)
public struct SessionDescription {
  public var version: Version
  public var origin: Origin
  public var sessionName: SessionName
  public var sessionInformation: SessionInformation?
  public var uri: URI?
  public var emailAddress: EmailAddress?
  public var phoneNumber: PhoneNumber?
  public var connectionInformation: ConnectionInformation?
  public var bandwidths: [Bandwidth]
  public var timeDescriptions: [TimeDescription]
  public var timeZones: [TimeZone]
  public var encryptionKey: EncryptionKey?
  public var attributes: [Attribute]
  public var mediaDescriptions: [MediaDescription]

  public init(
    version: Version,
    origin: Origin,
    sessionName: SessionName,
    sessionInformation: SessionInformation? = nil,
    uri: URI? = nil,
    emailAddress: EmailAddress? = nil,
    phoneNumber: PhoneNumber? = nil,
    connectionInformation: ConnectionInformation? = nil,
    bandwidths: [Bandwidth] = [],
    timeDescriptions: [TimeDescription],
    timeZones: [TimeZone] = [],
    encryptionKey: EncryptionKey? = nil,
    attributes: [Attribute] = [],
    mediaDescriptions: [MediaDescription] = []
  ) {
    self.version = version
    self.origin = origin
    self.sessionName = sessionName
    self.sessionInformation = sessionInformation
    self.uri = uri
    self.emailAddress = emailAddress
    self.phoneNumber = phoneNumber
    self.connectionInformation = connectionInformation
    self.bandwidths = bandwidths
    self.timeDescriptions = timeDescriptions
    self.timeZones = timeZones
    self.encryptionKey = encryptionKey
    self.attributes = attributes
    self.mediaDescriptions = mediaDescriptions
  }
}

extension SessionDescription {
  /// ```
  /// v=0
  /// ```
  ///
  /// [RFC4566-section-5.1](https://tools.ietf.org/html/rfc4566#section-5.1)
  public typealias Version = Int
  /// ```
  /// s=<session name>
  /// ```
  ///
  /// [RFC4566-section-5.3](https://tools.ietf.org/html/rfc4566#section-5.3)
  public typealias SessionName = String
  /// ```
  /// i=<session description>
  /// ```
  ///
  /// [RFC4566-section-5.4](https://tools.ietf.org/html/rfc4566#section-5.4)
  public typealias SessionInformation = String
  /// ```
  /// u=<uri>
  /// ```
  ///
  /// https://tools.ietf.org/html/rfc4566#section-5.5)
  public typealias URI = String
  /// ```
  /// e=<email-address>
  /// ```
  ///
  /// [RFC4566-section-5.6](https://tools.ietf.org/html/rfc4566#section-5.6)
  public typealias EmailAddress = String
  /// ```
  /// p=<phone-number>
  /// ```
  ///
  /// [RFC4566-section-5.6](https://tools.ietf.org/html/rfc4566#section-5.6)
  public typealias PhoneNumber = String
  /// ```
  /// k=<method>
  /// k=<method>:<encryption key>
  /// ```
  ///
  /// [RFC4566-section-5.12](https://tools.ietf.org/html/rfc4566#section-5.12)
  public typealias EncryptionKey = String
}

extension SessionDescription {
  public enum NetworkType: String {
    case internet = "IN"
  }

  public enum AddressType: String {
    case ipv4 = "IP4"
    case ipv6 = "IP6"
  }

  /// ```
  /// o=<username> <sess-id> <sess-version> <nettype> <addrtype> <unicast-address>
  /// ```
  ///
  /// [RFC4566-section-5.2](https://tools.ietf.org/html/rfc4566#section-5.2)
  public struct Origin {
    public var username: String
    public var sessionID: UInt64
    public var sessionVersion: UInt64
    public var networkType: NetworkType
    public var addressType: AddressType
    public var unicastAddress: String

    public init(
      username: String,
      sessionID: UInt64,
      sessionVersion: UInt64,
      networkType: NetworkType,
      addressType: AddressType,
      unicastAddress: String
    ) {
      self.username = username
      self.sessionID = sessionID
      self.sessionVersion = sessionVersion
      self.networkType = networkType
      self.addressType = addressType
      self.unicastAddress = unicastAddress
    }
  }
}

extension SessionDescription {
  /// ```
  /// <base multicast address>[/<ttl>]/<number of addresses>
  /// ```
  public struct Address {
    public var address: String
    public var ttl: UInt8
    public var range: Int

    public init(address: String, ttl: UInt8, range: Int) {
      self.address = address
      self.ttl = ttl
      self.range = range
    }
  }

  /// ```
  /// c=<nettype> <addrtype> <connection-address>
  /// ```
  ///
  /// [RFC4566-section-5.7](https://tools.ietf.org/html/rfc4566#section-5.7)
  public struct ConnectionInformation {
    public var networkType: NetworkType
    public var addressType: AddressType
    public var address: Address?

    public init(networkType: NetworkType, addressType: AddressType, address: Address?) {
      self.networkType = networkType
      self.addressType = addressType
      self.address = address
    }
  }
}

extension SessionDescription {
  /// ```
  /// b=<bwtype>:<bandwidth>
  /// ```
  ///
  /// [RFC4566-section-5.8](https://tools.ietf.org/html/rfc4566#section-5.8)
  public struct Bandwidth {
    public var type: Kind
    public var bandwidth: UInt64

    public init(type: Kind, bandwidth: UInt64) {
      self.type = type
      self.bandwidth = bandwidth
    }
  }
}

extension SessionDescription.Bandwidth {
  public enum Kind: String {
    case ct = "CT"
    case `as` = "AS"
  }
}

extension SessionDescription {
  /// ```
  /// t=<start-time> <stop-time>
  /// ```
  ///
  /// https://tools.ietf.org/html/rfc4566#section-5.9
  public struct Timing {
    public var startTime: UInt64
    public var stopTime: UInt64

    public init(startTime: UInt64, stopTime: UInt64) {
      self.startTime = startTime
      self.stopTime = stopTime
    }
  }

  /// ```
  /// r=<repeat interval> <active duration> <offsets from start-time>
  /// ```
  ///
  /// https://tools.ietf.org/html/rfc4566#section-5.10
  public struct RepeatTime {
    public var interval: Int64
    public var duration: Int64
    public var offsets: [Int64]

    public init(interval: Int64, duration: Int64, offsets: [Int64]) {
      self.interval = interval
      self.duration = duration
      self.offsets = offsets
    }
  }

  public struct TimeDescription {
    public var timing: Timing
    public var repeatTimes: [RepeatTime]

    public init(timing: Timing, repeatTimes: [RepeatTime] = []) {
      self.timing = timing
      self.repeatTimes = repeatTimes
    }
  }
}

extension SessionDescription {
  /// ```
  /// z=<adjustment time> <offset> <adjustment time> <offset> ...
  /// ```
  ///
  /// [RFC4566-section-5.11](https://tools.ietf.org/html/rfc4566#section-5.11)
  public struct TimeZone {
    public var adjustmentTime: UInt64
    public var offset: Int64

    public init(adjustmentTime: UInt64, offset: Int64) {
      self.adjustmentTime = adjustmentTime
      self.offset = offset
    }
  }
}

extension SessionDescription {
  /// ```
  /// a=<attribute>
  /// a=<attribute>:<value>
  /// ```
  ///
  /// [RFC4566-section-5.13](https://tools.ietf.org/html/rfc4566#section-5.13)
  public struct Attribute {
    public var key: Key
    public var value: String?

    public init(key: Key, value: String?) {
      self.key = key
      self.value = value
    }
  }
}

extension SessionDescription.Attribute {
  public struct Key: Equatable, ExpressibleByStringLiteral {
    var rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
      self.rawValue = value
    }
  }
}

extension SessionDescription {
  public struct RangedPort {
    public var value: UInt16
    public var range: Int?

    public init(value: UInt16, range: Int?) {
      self.value = value
      self.range = range
    }
  }

  public enum Media: String {
    case audio
    case video
    case text
    case application
    case message
  }

  public enum Proto: String {
    case udp = "UDP"
    case rtp = "RTP"
    case avp = "AVP"
    case savp = "SAVP"
    case avpf = "AVPF"
    case savpf = "SAVPF"
    case tls = "TLS"
    case dtls = "DTLS"
    case sctp = "SCTP"
  }

  /// ```
  /// m=<media> <port>/<number of ports> <proto> <fmt> ...
  /// ```
  ///
  /// [RFC4566-section-5.14](https://tools.ietf.org/html/rfc4566#section-5.14)
  public struct MediaName {
    public var media: Media
    public var port: RangedPort
    public var protos: [Proto]
    public var formats: [String]

    public init(media: Media, port: RangedPort, protos: [Proto], formats: [String]) {
      self.media = media
      self.port = port
      self.protos = protos
      self.formats = formats
    }
  }

  /// ```
  /// i=<session description>
  /// ```
  ///
  /// [RFC4566-section-5.4](https://tools.ietf.org/html/rfc4566#section-5.4)
  public typealias MediaTitle = String

  /// MediaDescription represents a media type.
  ///
  /// [RFC4566-section-5.14](https://tools.ietf.org/html/rfc4566#section-5.14)
  public struct MediaDescription {
    public var mediaName: MediaName
    public var mediaTitle: MediaTitle?
    public var connectionInformation: ConnectionInformation?
    public var bandwidths: [Bandwidth]
    public var encryptionKey: EncryptionKey?
    public var attributes: [Attribute]

    public init(
      mediaName: MediaName,
      mediaTitle: MediaTitle? = nil,
      connectionInformation: ConnectionInformation? = nil,
      bandwidths: [Bandwidth] = [],
      encryptionKey: EncryptionKey? = nil,
      attributes: [Attribute] = []
    ) {
      self.mediaName = mediaName
      self.mediaTitle = mediaTitle
      self.connectionInformation = connectionInformation
      self.bandwidths = bandwidths
      self.encryptionKey = encryptionKey
      self.attributes = attributes
    }
  }
}
