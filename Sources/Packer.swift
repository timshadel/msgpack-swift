import Foundation


// MARK: - Main Types

public protocol MsgPackValueType {

    func pack(data: NSMutableData) throws -> NSMutableData

}

public enum MsgPackError: ErrorType {
    case UnsupportedValue(MsgPackValueType)
    case NonUTF8StringValue(String)
    case ValueTooLong(Any)
}

struct Packer {

    func pack(object: MsgPackValueType) throws -> NSData {
        let data = NSMutableData()
        return try object.pack(data)
    }

    func pack<T: MsgPackValueType>(array: Array<T>) throws -> NSData {
        let data = NSMutableData()
        return try array.pack(data)
    }

}


// MARK: - Extensions

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

}

extension Int16: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xd1
        var value = CFSwapInt16HostToBig(UInt16(bitPattern: self))
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 2)
        return data
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

}

extension Int64: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xd3
        var value = CFSwapInt64HostToBig(UInt64(bitPattern: self))
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 8)
        return data
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

}

extension UInt16: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xcd
        var value = CFSwapInt16HostToBig(self)
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 2)
        return data
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

}

extension UInt64: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xcf
        var value = CFSwapInt64HostToBig(self)
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 8)
        return data
    }

}


extension Float: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xca
        var value = CFConvertFloat32HostToSwapped(self)
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 4)
        return data
    }

}

// extension Double: MsgPackValueType {
//
//     public func pack(data: NSMutableData) -> NSMutableData {
//         var type = 0xcb
//         var value = CFConvertDoubleSwappedToHost(Float64(self))
//         data.appendBytes(&type, length: 1)
//         data.appendBytes(&value, length: 8)
//         return data
//     }
//
// }

extension Bool: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var value = self ? 0xc3 : 0xc2
        data.appendBytes(&value, length: 1)
        return data
    }

}

extension String: MsgPackValueType {

    public func pack(data: NSMutableData) throws -> NSMutableData {
        guard let strdata = self.dataUsingEncoding(NSUTF8StringEncoding) else { throw MsgPackError.NonUTF8StringValue(self) }
        let length = strdata.length
        if length < 32 {
            var type = 0b10100000 + length
            data.appendBytes(&type, length: 1)
            data.appendData(strdata)
        } else if length <= Int(UInt8.max) {
            var type = 0xd9
            var len = UInt8(length)
            data.appendBytes(&type, length: 1)
            data.appendBytes(&len, length: 1)
            data.appendData(strdata)
        } else if length <= Int(UInt16.max) {
            var type = 0xda
            var len = CFSwapInt16HostToBig(UInt16(length))
            data.appendBytes(&type, length: 1)
            data.appendBytes(&len, length: 2)
            data.appendData(strdata)
        } else if length <= Int(UInt32.max) {
            var type = 0xdb
            var len = CFSwapInt32HostToBig(UInt32(length))
            data.appendBytes(&type, length: 1)
            data.appendBytes(&len, length: 4)
            data.appendData(strdata)
        } else {
            throw MsgPackError.ValueTooLong(self)
        }
        return data
    }

}

extension NSData: MsgPackValueType {

    public func pack(data: NSMutableData) throws -> NSMutableData {
        let length = self.length
        if length <= Int(UInt8.max) {
            var type = 0xc4
            var len = UInt8(length)
            data.appendBytes(&type, length: 1)
            data.appendBytes(&len, length: 1)
            data.appendData(self)
        } else if length <= Int(UInt16.max) {
            var type = 0xc5
            var len = CFSwapInt16HostToBig(UInt16(length))
            data.appendBytes(&type, length: 1)
            data.appendBytes(&len, length: 2)
            data.appendData(self)
        } else if length <= Int(UInt32.max) {
            var type = 0xc6
            var len = CFSwapInt32HostToBig(UInt32(length))
            data.appendBytes(&type, length: 1)
            data.appendBytes(&len, length: 4)
            data.appendData(self)
        } else {
            throw MsgPackError.ValueTooLong(self)
        }
        return data
    }

}

/// Sadly, this does not allow for nested arrays. Ideas welcome.
extension Array where Element: MsgPackValueType {

    public func pack(data: NSMutableData) throws -> NSMutableData {
        let length = self.count
        if length < 16 {
            var type = 0b10010000 + length
            data.appendBytes(&type, length: 1)
        } else if length <= Int(UInt16.max) {
            var type = 0xdc
            var len = CFSwapInt16HostToBig(UInt16(length))
            data.appendBytes(&type, length: 1)
            data.appendBytes(&len, length: 2)
        } else if length <= Int(UInt32.max) {
            var type = 0xdd
            var len = CFSwapInt32HostToBig(UInt32(length))
            data.appendBytes(&type, length: 1)
            data.appendBytes(&len, length: 4)
        } else {
            throw MsgPackError.ValueTooLong(self)
        }
        for object in self {
            try object.pack(data)
        }
        return data
    }

}
