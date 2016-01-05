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

    public static func unpack<G: GeneratorType where G.Element == UInt8>(inout generator: G) throws -> Float {
        let value = try UInt32.unpack(&generator)
        return unsafeBitCast(value, Float.self)
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

    public static func unpack<G: GeneratorType where G.Element == UInt8>(inout generator: G) throws -> Double {
        let value = try UInt64.unpack(&generator)
        return unsafeBitCast(value, Double.self)
    }

}
