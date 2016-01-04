//
// Implementation of msgpack int family format.
//  https://github.com/msgpack/msgpack/blob/master/spec.md#formats-int
//
import Foundation


extension Int: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        if self >= Int(Int8.min) && self <= Int(Int8.max) {
            return Int8(self).pack(data)
        } else if self >= Int(Int16.min) && self <= Int(Int16.max) {
            return Int16(self).pack(data)
        } else if self >= Int(Int32.min) && self <= Int(Int32.max) {
            return Int32(self).pack(data)
        } else {
            return Int64(self).pack(data)
        }
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(data)
    }

}


extension Int8: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        if self >= -32 && self < 0 {
            var value = self
            data.appendBytes(&value, length: 1)
        } else {
            var type = 0xd0
            var value = self
            data.appendBytes(&type, length: 1)
            data.appendBytes(&value, length: 1)
        }
        return data
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(data)
    }

}


extension Int16: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xd1
        var value = CFSwapInt16HostToBig(UInt16(bitPattern: self))
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 2)
        return data
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(data)
    }

}


extension Int32: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xd2
        var value = CFSwapInt32HostToBig(UInt32(bitPattern: self))
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 4)
        return data
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(data)
    }

}


extension Int64: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xd3
        var value = CFSwapInt64HostToBig(UInt64(bitPattern: self))
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 8)
        return data
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(data)
    }

}


extension UInt: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        if self <= UInt(UInt8.max) {
            return UInt8(self).pack(data)
        } else if self <= UInt(UInt16.max) {
            return UInt16(self).pack(data)
        } else if self <= UInt(UInt32.max) {
            return UInt32(self).pack(data)
        } else {
            return UInt64(self).pack(data)
        }
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(data)
    }

}


extension UInt8: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        if self <= 0b01111111 {
            var value = self
            data.appendBytes(&value, length: 1)
        } else {
            var type = 0xcc
            var value = self
            data.appendBytes(&type, length: 1)
            data.appendBytes(&value, length: 1)
        }
        return data
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(data)
    }

}


extension UInt16: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xcd
        var value = CFSwapInt16HostToBig(self)
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 2)
        return data
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(data)
    }

}


extension UInt32: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xce
        var value = CFSwapInt32HostToBig(self)
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 4)
        return data
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(data)
    }

}


extension UInt64: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xcf
        var value = CFSwapInt64HostToBig(self)
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 8)
        return data
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(data)
    }

}
