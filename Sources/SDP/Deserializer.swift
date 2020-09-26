//
//  Deserializer.swift
//  webrtc-sdp
//
//  Created by sunlubo on 2020/9/4.
//  Copyright © 2020 sunlubo. All rights reserved.
//

import Core

extension SessionDescription {

  public static func deserialize(from string: String) throws -> Self {
    var parser = SDPParser(source: string)
    return try parser.parse()
  }
}

extension ICECandidate {
  // https://tools.ietf.org/html/draft-ietf-mmusic-ice-sip-sdp-24#section-4.1
  //
  //  candidate-attribute   = "candidate" ":" foundation SP component-id SP
  //                          transport SP
  //                          priority SP
  //                          connection-address SP     ;from RFC 4566
  //                          port         ;port from RFC 4566
  //                          SP cand-type
  //                          [SP rel-addr]
  //                          [SP rel-port]
  //                          *(SP extension-att-name SP
  //                               extension-att-value)
  //
  //  foundation            = 1*32ice-char
  //  component-id          = 1*5DIGIT
  //  transport             = "UDP" / transport-extension
  //  transport-extension   = token              ; from RFC 3261
  //  priority              = 1*10DIGIT
  //  cand-type             = "typ" SP candidate-types
  //  candidate-types       = "host" / "srflx" / "prflx" / "relay" / token
  //  rel-addr              = "raddr" SP connection-address
  //  rel-port              = "rport" SP port
  //  extension-att-name    = token
  //  extension-att-value   = *VCHAR
  //  ice-char              = ALPHA / DIGIT / "+" / "/"
  public static func deserialize(from string: String) throws -> Self {
    let fields = string.split(separator: " ").map(String.init)
    guard fields.count >= 8 else {
      throw SDPError(message: "Invalid candidate: \(string)")
    }

    let component = try UInt16(fields[1]).unwrap(
      or: SDPError(message: "Invalid <component-id>: \(fields[1])")
    )
    let priority = try UInt32(fields[3]).unwrap(
      or: SDPError(message: "Invalid <priority>: \(fields[3])")
    )
    let port = try UInt16(fields[5]).unwrap(
      or: SDPError(message: "Invalid <port>: \(fields[5])")
    )
    let type = try ICECandidate.Kind(rawValue: fields[7]).unwrap(
      or: SDPError(message: "Invalid <cand-type>: \(fields[7])")
    )

    var relatedAddress: String?
    var relatedPort: UInt16?
    if fields.count > 8 {
      if fields[8] == "raddr" {
        guard fields.count >= 12 else {
          throw SDPError(message: "Invalid <rel-addr>: \(fields)")
        }

        relatedAddress = fields[9]
        relatedPort = try UInt16(fields[11]).unwrap(
          or: SDPError(message: "Invalid <rel-port>: \(fields[11])")
        )
      }
    }

    var attributes = [ICECandidate.Attribute]()
    for i in stride(from: relatedAddress == nil ? 8 : 12, to: fields.count, by: 2) {
      attributes.append(.init(key: fields[i], value: fields[i + 1]))
    }

    return .init(
      foundation: fields[0],
      component: component,
      proto: fields[2],
      priority: priority,
      address: fields[4],
      port: port,
      type: type,
      relatedAddress: relatedAddress,
      relatedPort: relatedPort,
      extensionAttributes: attributes
    )
  }
}

extension ExtMap {

  // a=extmap:<value>["/"<direction>] <URI> <extensionattributes>
  public static func deserialize(from string: String) throws -> Self {
    let fields = string.split(separator: " ").map(String.init)
    guard fields.count >= 2 else {
      throw SDPError(message: "Invalid extmap: \(string)")
    }

    let parts = fields[0].split(separator: "/").map(String.init)
    guard let value = Int(parts[0]), value >= 1, value <= 256 else {
      throw SDPError(message: "Invalid <value>: \(parts[0])")
    }

    var direction: ExtMap.Direction?
    if parts.count == 2 {
      direction = try ExtMap.Direction(rawValue: parts[1]).unwrap(
        or: SDPError(message: "Invalid <direction>: \(parts[1])")
      )
    }

    return .init(
      value: value,
      direction: direction,
      uri: .init(rawValue: fields[1]),
      extensionAttributes: fields.count > 2 ? fields[2] : nil
    )
  }
}

// Session description
//    v=  (protocol version)
//    o=  (originator and session identifier)
//    s=  (session name)
//    i=* (session information)
//    u=* (URI of description)
//    e=* (email address)
//    p=* (phone number)
//    c=* (connection information -- not required if included in
//         all media)
//    b=* (zero or more bandwidth information lines)
//    One or more time descriptions ("t=" and "r=" lines; see below)
//    z=* (time zone adjustments)
//    k=* (encryption key)
//    a=* (zero or more session attribute lines)
//    Zero or more media descriptions
//
// Time description
//    t=  (time the session is active)
//    r=* (zero or more repeat times)
//
// Media description, if present
//    m=  (media name and transport address)
//    i=* (media title)
//    c=* (connection information -- optional if included at
//         session level)
//    b=* (zero or more bandwidth information lines)
//    k=* (encryption key)
//    a=* (zero or more media attribute lines)
struct SDPParser {
  var lines: [String]
  var index: Array<String>.Index
  var current: String? {
    index < lines.endIndex ? lines[index] : nil
  }

  init(source: String) {
    self.lines = source.split(separator: "\n").map(String.init)
    self.index = lines.startIndex
  }

  mutating func advance() {
    lines.formIndex(after: &index)
  }

  mutating func parse() throws -> SessionDescription {
    let version = try parseProtocolVersion()
    let origin = try parseOrigin()
    let sessionName = try parseSessionName()
    let sessionInformation = try parseSessionInformation()
    let uri = try parseURI()
    let emailAddress = try parseEmailAddress()
    let phoneNumber = try parsePhoneNumber()
    let connectionInformation = try parseConnectionInformation()
    let bandwidths = try parseBandwidths()
    let timeZones = try parseTimeZones()
    let timeDescriptions = try parseTimeDescriptions()
    let encryptionKey = try parseEncryptionKey()
    let attributes = try parseAttributes()
    let mediaDescriptions = try parseMediaDescriptions()
    return .init(
      version: version,
      origin: origin,
      sessionName: sessionName,
      sessionInformation: sessionInformation,
      uri: uri,
      emailAddress: emailAddress,
      phoneNumber: phoneNumber,
      connectionInformation: connectionInformation,
      bandwidths: bandwidths,
      timeDescriptions: timeDescriptions,
      timeZones: timeZones,
      encryptionKey: encryptionKey,
      attributes: attributes,
      mediaDescriptions: mediaDescriptions
    )
  }

  /// ```
  /// v=0
  /// ```
  ///
  /// [RFC4566-section-5.1](https://tools.ietf.org/html/rfc4566#section-5.1)
  mutating func parseProtocolVersion() throws -> Int {
    guard let line = current, line.prefix(2) == "v=" else {
      throw SDPError(message: "Invalid v=")
    }

    // As off the latest draft of the rfc this value is required to be 0.
    // https://tools.ietf.org/html/draft-ietf-rtcweb-jsep-24#section-5.8.1
    guard let version = Int(line.dropFirst(2)), version == 0 else {
      throw SDPError(message: "Invalid line: \(line)")
    }

    advance()
    return version
  }

  /// ```
  /// o=<username> <sess-id> <sess-version> <nettype> <addrtype> <unicast-address>
  /// ```
  ///
  /// [RFC4566-section-5.2](https://tools.ietf.org/html/rfc4566#section-5.2)
  mutating func parseOrigin() throws -> SessionDescription.Origin {
    guard let line = current, line.prefix(2) == "o=" else {
      throw SDPError(message: "Invalid o=")
    }

    let fields = line.dropFirst(2).split(separator: " ").map(String.init)
    guard fields.count == 6 else {
      throw SDPError(message: "Invalid line: \(line)")
    }

    let sessionID = try UInt64(fields[1]).unwrap(
      or: SDPError(message: "Invalid <sess-id>: \(fields[1])")
    )
    let sessionVersion = try UInt64(fields[2]).unwrap(
      or: SDPError(message: "Invalid <sess-version>: \(fields[2])")
    )
    let networkType = try SessionDescription.NetworkType(rawValue: fields[3]).unwrap(
      or: SDPError(message: "Invalid <nettype>: \(fields[3])")
    )
    let addressType = try SessionDescription.AddressType(rawValue: fields[4]).unwrap(
      or: SDPError(message: "Invalid <addrtype>: \(fields[4])")
    )

    advance()
    return .init(
      username: fields[0],
      sessionID: sessionID,
      sessionVersion: sessionVersion,
      networkType: networkType,
      addressType: addressType,
      unicastAddress: fields[5]
    )
  }

  /// ```
  /// s=<session name>
  /// ```
  ///
  /// [RFC4566-section-5.3](https://tools.ietf.org/html/rfc4566#section-5.3)
  mutating func parseSessionName() throws -> String {
    guard let line = current, line.prefix(2) == "s=" else {
      throw SDPError(message: "Invalid s=")
    }

    advance()
    return String(line.dropFirst(2))
  }

  /// ```
  /// i=<session description>
  /// ```
  ///
  /// [RFC4566-section-5.4](https://tools.ietf.org/html/rfc4566#section-5.4)
  mutating func parseSessionInformation() throws -> String? {
    guard let line = current, line.prefix(2) == "i=" else {
      return nil
    }

    advance()
    return String(line.dropFirst(2))
  }

  /// ```
  /// u=<uri>
  /// ```
  ///
  /// https://tools.ietf.org/html/rfc4566#section-5.5)
  mutating func parseURI() throws -> String? {
    guard let line = current, line.prefix(2) == "u=" else {
      return nil
    }

    advance()
    return String(line.dropFirst(2))
  }

  /// ```
  /// e=<email-address>
  /// ```
  ///
  /// [RFC4566-section-5.6](https://tools.ietf.org/html/rfc4566#section-5.6)
  mutating func parseEmailAddress() throws -> String? {
    guard let line = current, line.prefix(2) == "e=" else {
      return nil
    }

    advance()
    return String(line.dropFirst(2))
  }

  /// ```
  /// p=<phone-number>
  /// ```
  ///
  /// [RFC4566-section-5.6](https://tools.ietf.org/html/rfc4566#section-5.6)
  mutating func parsePhoneNumber() throws -> String? {
    guard let line = current, line.prefix(2) == "p=" else {
      return nil
    }

    advance()
    return String(line.dropFirst(2))
  }

  /// ```
  /// c=<nettype> <addrtype> <connection-address>
  /// ```
  ///
  /// [RFC4566-section-5.7](https://tools.ietf.org/html/rfc4566#section-5.7)
  mutating func parseConnectionInformation() throws -> SessionDescription.ConnectionInformation? {
    guard let line = current, line.prefix(2) == "c=" else {
      return nil
    }

    let fields = line.dropFirst(2).split(separator: " ").map(String.init)
    guard fields.count >= 2 else {
      throw SDPError(message: "Invalid line: \(line)")
    }

    let networkType = try SessionDescription.NetworkType(rawValue: fields[0]).unwrap(
      or: SDPError(message: "Invalid <nettype>: \(fields[0])")
    )
    let addressType = try SessionDescription.AddressType(rawValue: fields[1]).unwrap(
      or: SDPError(message: "Invalid <addrtype>: \(fields[1])")
    )

    advance()
    return .init(
      networkType: networkType,
      addressType: addressType,
      address: fields.count > 2 ? .init(address: fields[2], ttl: 0, range: 0) : nil
    )
  }

  mutating func parseBandwidths() throws -> [SessionDescription.Bandwidth] {
    var bandwidths = [SessionDescription.Bandwidth]()
    while let bandwidth = try parseBandwidth() {
      bandwidths.append(bandwidth)
    }
    return bandwidths
  }

  /// ```
  /// b=<bwtype>:<bandwidth>
  /// ```
  ///
  /// [RFC4566-section-5.8](https://tools.ietf.org/html/rfc4566#section-5.8)
  mutating func parseBandwidth() throws -> SessionDescription.Bandwidth? {
    guard let line = current, line.prefix(2) == "b=" else {
      return nil
    }

    let parts = line.dropFirst(2).split(separator: ":").map(String.init)
    guard parts.count != 2 else {
      throw SDPError(message: "Invalid line: \(line)")
    }

    let type = try SessionDescription.Bandwidth.Kind(rawValue: parts[0]).unwrap(
      or: SDPError(message: "Invalid <bwtype>: \(parts[0])")
    )
    let bandwidth = try UInt64(parts[1]).unwrap(
      or: SDPError(message: "Invalid <bandwidth>: \(parts[1])")
    )

    advance()
    return .init(type: type, bandwidth: bandwidth)
  }

  mutating func parseTimeDescriptions() throws -> [SessionDescription.TimeDescription] {
    var descriptions = [SessionDescription.TimeDescription]()
    while let timing = try parseTiming() {
      let repeatTimes = try parseRepeatTimes()
      descriptions.append(.init(timing: timing, repeatTimes: repeatTimes))
    }
    return descriptions
  }

  /// ```
  /// t=<start-time> <stop-time>
  /// ```
  ///
  /// https://tools.ietf.org/html/rfc4566#section-5.9
  mutating func parseTiming() throws -> SessionDescription.Timing? {
    guard let line = current, line.prefix(2) == "t=" else {
      return nil
    }

    let fields = line.dropFirst(2).split(separator: " ")
    guard fields.count == 2 else {
      throw SDPError(message: "Invalid line: \(line)")
    }

    let startTime = try UInt64(fields[0]).unwrap(
      or: SDPError(message: "Invalid <start-time>: \(fields[0])")
    )
    let stopTime = try UInt64(fields[1]).unwrap(
      or: SDPError(message: "Invalid <stop-time>: \(fields[1])")
    )

    advance()
    return .init(startTime: startTime, stopTime: stopTime)
  }

  mutating func parseRepeatTimes() throws -> [SessionDescription.RepeatTime] {
    var repeatTimes = [SessionDescription.RepeatTime]()
    while let repeatTime = try parseRepeatTime() {
      repeatTimes.append(repeatTime)
    }
    return repeatTimes
  }

  /// ```
  /// r=<repeat interval> <active duration> <offsets from start-time>
  /// ```
  ///
  /// https://tools.ietf.org/html/rfc4566#section-5.10
  mutating func parseRepeatTime() throws -> SessionDescription.RepeatTime? {
    guard let line = current, line.prefix(2) == "r=" else {
      return nil
    }

    let fields = line.dropFirst(2).split(separator: " ")
    guard fields.count >= 3 else {
      throw SDPError(message: "Invalid line: \(line)")
    }

    let interval = try parseTimeUnits(fields[0])
    let duration = try parseTimeUnits(fields[1])
    let offsets = try fields.dropFirst(2).map(parseTimeUnits)

    advance()
    return .init(interval: interval, duration: duration, offsets: offsets)
  }

  /// ```
  /// z=<adjustment time> <offset> <adjustment time> <offset> ...
  /// ```
  ///
  /// [RFC4566-section-5.11](https://tools.ietf.org/html/rfc4566#section-5.11)
  mutating func parseTimeZones() throws -> [SessionDescription.TimeZone] {
    guard let line = current, line.prefix(2) == "z=" else {
      return []
    }

    let fields = line.dropFirst(2).split(separator: " ")
    guard fields.count % 2 == 0 else {
      throw SDPError(message: "Invalid line: \(line)")
    }

    var timeZones = [SessionDescription.TimeZone]()
    for i in stride(from: 0, to: fields.count, by: 2) {
      let adjustmentTime = try UInt64(fields[i]).unwrap(
        or: SDPError(message: "Invalid <adjustment time>: \(fields[i])")
      )
      let offset = try parseTimeUnits(fields[i + 1])
      timeZones.append(.init(adjustmentTime: adjustmentTime, offset: offset))
    }

    advance()
    return timeZones
  }

  /// ```
  /// k=<method>
  /// k=<method>:<encryption key>
  /// ```
  ///
  /// [RFC4566-section-5.12](https://tools.ietf.org/html/rfc4566#section-5.12)
  mutating func parseEncryptionKey() throws -> String? {
    guard let line = current, line.prefix(2) == "k=" else {
      return nil
    }

    advance()
    return String(line.dropFirst(2))
  }

  /// ```
  /// a=<attribute>
  /// a=<attribute>:<value>
  /// ```
  ///
  /// [RFC4566-section-5.13](https://tools.ietf.org/html/rfc4566#section-5.13)
  mutating func parseAttributes() throws -> [SessionDescription.Attribute] {
    var attributes = [SessionDescription.Attribute]()
    while let attribute = try parseAttribute() {
      attributes.append(attribute)
    }
    return attributes
  }

  /// ```
  /// a=<attribute>
  /// a=<attribute>:<value>
  /// ```
  ///
  /// [RFC4566-section-5.13](https://tools.ietf.org/html/rfc4566#section-5.13)
  mutating func parseAttribute() throws -> SessionDescription.Attribute? {
    guard let line = current, line.prefix(2) == "a=" else {
      return nil
    }

    let key: String
    let value: String?
    if let index = line.firstIndex(of: ":") {
      key = String(line[line.index(line.startIndex, offsetBy: 2) ..< index])
      value = String(line[line.index(after: index)...])
    } else {
      key = String(line[line.index(line.startIndex, offsetBy: 2)...])
      value = nil
    }

    advance()
    return .init(key: .init(rawValue: key), value: value)
  }

  mutating func parseMediaDescriptions() throws -> [SessionDescription.MediaDescription] {
    var descriptions = [SessionDescription.MediaDescription]()
    while let mediaName = try parseMediaName() {
      let mediaTitle = try parseSessionInformation()
      let connectionInformation = try parseConnectionInformation()
      let bandwidths = try parseBandwidths()
      let encryptionKey = try parseEncryptionKey()
      let attributes = try parseAttributes()
      descriptions.append(
        .init(
          mediaName: mediaName,
          mediaTitle: mediaTitle,
          connectionInformation: connectionInformation,
          bandwidths: bandwidths,
          encryptionKey: encryptionKey,
          attributes: attributes
        )
      )
    }
    return descriptions
  }

  /// ```
  /// m=<media> <port>/<number of ports> <proto> <fmt> ...
  /// ```
  ///
  /// [RFC4566-section-5.14](https://tools.ietf.org/html/rfc4566#section-5.14)
  mutating func parseMediaName() throws -> SessionDescription.MediaName? {
    guard let line = current, line.prefix(2) == "m=" else {
      return nil
    }

    let fields = line.dropFirst(2).split(separator: " ").map(String.init)
    guard fields.count >= 4 else {
      throw SDPError(message: "Invalid line: \(line)")
    }

    // <media>
    let media = try SessionDescription.Media(rawValue: fields[0]).unwrap(
      or: SDPError(message: "Invalid <media>: \(fields[0])")
    )
    // <port>
    let parts = fields[1].split(separator: "/")
    let port = try UInt16(parts[0]).unwrap(
      or: SDPError(message: "Invalid <port>: \(parts[0])")
    )
    var range: Int?
    if parts.count > 1 {
      range = try Int(parts[1]).unwrap(
        or: SDPError(message: "Invalid <number of ports>: \(parts[1])")
      )
    }
    // <proto>
    let protos = try fields[2]
      .split(separator: "/")
      .map {
        try SessionDescription.Proto(rawValue: String($0)).unwrap(
          or: SDPError(message: "Invalid <proto>: \($0)")
        )
      }

    advance()
    return .init(
      media: media,
      port: .init(value: port, range: range),
      protos: protos,
      formats: fields.dropFirst(3).map(String.init)
    )
  }

  func parseTimeUnits<S: StringProtocol>(_ string: S) throws -> Int64 {
    switch string.last {
    case "d":
      if let value = Int64(string.dropLast()) {
        return value * 86400
      }
    case "h":
      if let value = Int64(string.dropLast()) {
        return value * 3600
      }
    case "m":
      if let value = Int64(string.dropLast()) {
        return value * 60
      }
    default:
      if let value = Int64(string) {
        return value
      }
    }
    throw SDPError(message: "Invalid time units: \(string)")
  }
}
