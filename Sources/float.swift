//
// Implementation of msgpack float family format.
//  https://github.com/msgpack/msgpack/blob/master/spec.md#formats-float
//
import Foundation


extension Float: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xca
        var value = CFConvertFloat32HostToSwapped(self)
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 4)
        return data
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        guard data.length == 5 else { throw MsgPackError.UnsupportedValue(data) }

        var type: UInt8 = 0
        data.getBytes(&type, length: 1)
        guard type == 0xca else { throw MsgPackError.UnsupportedValue(data) }

        var value: CFSwappedFloat32 = CFSwappedFloat32(v: 0)
        data.getBytes(&value, range: NSMakeRange(1, 4))
        return CFConvertFloat32SwappedToHost(value)
    }

}


extension Double: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var type = 0xcb
        var value = CFConvertDoubleHostToSwapped(self)
        data.appendBytes(&type, length: 1)
        data.appendBytes(&value, length: 8)
        return data
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        guard data.length == 9 else { throw MsgPackError.UnsupportedValue(data) }

        var type: UInt8 = 0
        data.getBytes(&type, length: 1)
        guard type == 0xcb else { throw MsgPackError.UnsupportedValue(data) }

        var value: CFSwappedFloat64 = CFSwappedFloat64(v: 0)
        data.getBytes(&value, range: NSMakeRange(1, 8))
        return CFConvertFloat64SwappedToHost(value)
    }

}
