//
//  Serializer.swift
//  sdp
//
//  Created by sunlubo on 2020/9/4.
//  Copyright © 2020 sunlubo. All rights reserved.
//

extension SessionDescription {

  public func serialize() -> String {
    var string = ""
    string.append("v=0")
    string.append("\n")
    string.append(origin.serialize())
    string.append("\n")
    string.append("s=\(sessionName)")
    sessionInformation.map { i in
      string.append("\n")
      string.append("i=\(i)")
    }
    uri.map { u in
      string.append("\n")
      string.append("u=\(u)")
    }
    emailAddress.map { e in
      string.append("\n")
      string.append("e=\(e)")
    }
    phoneNumber.map { p in
      string.append("\n")
      string.append("p=\(p)")
    }
    connectionInformation.map { c in
      string.append("\n")
      string.append("c=\(c)")
    }
    bandwidths.forEach { b in
      string.append("\n")
      string.append(b.serialize())
    }
    timeDescriptions.forEach { t in
      string.append("\n")
      string.append(t.serialize())
    }
    timeZones.forEach { z in
      string.append("\n")
      string.append(z.serialize())
    }
    encryptionKey.map { k in
      string.append("\n")
      string.append("k=\(k)")
    }
    attributes.forEach { a in
      string.append("\n")
      string.append(a.serialize())
    }
    mediaDescriptions.forEach { m in
      string.append("\n")
      string.append(m.serialize())
    }
    return string
  }
}

extension SessionDescription.Origin {

  public func serialize() -> String {
    "o=\(username) \(sessionID) \(sessionVersion) \(networkType.rawValue) \(addressType.rawValue) \(unicastAddress)"
  }
}

extension SessionDescription.ConnectionInformation {

  public func serialize() -> String {
    "c=\(networkType.rawValue) \(addressType.rawValue)\(address.map({ " \($0.address)"}) ?? "")"
  }
}

extension SessionDescription.Bandwidth {

  public func serialize() -> String {
    "b=\(type.rawValue):\(bandwidth)"
  }
}

extension SessionDescription.TimeDescription {

  public func serialize() -> String {
    var string = timing.serialize()
    repeatTimes.forEach { r in
      string.append("\n")
      string.append(r.serialize())
    }
    return string
  }
}

extension SessionDescription.Timing {

  public func serialize() -> String {
    "t=\(startTime) \(stopTime)"
  }
}

extension SessionDescription.RepeatTime {

  public func serialize() -> String {
    "r=\(interval) \(duration) \(offsets)"
  }
}

extension SessionDescription.TimeZone {

  public func serialize() -> String {
    "z=\(adjustmentTime) \(offset)"
  }
}

extension SessionDescription.Attribute {

  public func serialize() -> String {
    "a=\(key.rawValue)\(value.map({ ":\($0)" }) ?? "")"
  }
}

extension SessionDescription.MediaDescription {

  public func serialize() -> String {
    var string = mediaName.serialize()
    mediaTitle.map { i in
      string.append("\n")
      string.append("i=\(i)")
    }
    connectionInformation.map { c in
      string.append("\n")
      string.append(c.serialize())
    }
    bandwidths.forEach { b in
      string.append("\n")
      string.append(b.serialize())
    }
    encryptionKey.map { k in
      string.append("\n")
      string.append("k=\(k)")
    }
    attributes.forEach { a in
      string.append("\n")
      string.append(a.serialize())
    }
    return string
  }
}

extension SessionDescription.MediaName {

  public func serialize() -> String {
    var string = "m="
    string.append("\(media.rawValue) ")
    string.append("\(port.value) ")
    string.append(port.range.map({ "/\($0)" }) ?? "")
    string.append(contentsOf: protos.reduce("", { $0 + "\($1.rawValue)/" }).dropLast())
    string.append(formats.reduce("", { $0 + " \($1)" }))
    return string
  }
}

extension ExtMap {

  public func serialize() -> String {
    var string = ""
    string.append("\(value)")
    string.append(direction.map({ "/\($0.rawValue)" }) ?? "")
    string.append(" \(uri.rawValue)")
    string.append(extensionAttributes.map({ " \($0)" }) ?? "")
    return string
  }
}

extension ICECandidate {

  public func serialize() -> String {
    var string = ""
    string.append("\(foundation) ")
    string.append("\(component) ")
    string.append("\(proto) ")
    string.append("\(priority) ")
    string.append("\(address) ")
    string.append("\(port) ")
    string.append("typ \(type)")
    string.append(relatedAddress.map({ " raddr \($0)" }) ?? "")
    string.append(relatedPort.map({ " rport \($0)" }) ?? "")
    string.append(extensionAttributes.reduce("", { $0 + " \($1)" }))
    return string
  }
}
