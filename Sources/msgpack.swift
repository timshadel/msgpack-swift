import Foundation


// MARK: - Main Types

public protocol MsgPackValueType {
    func pack(data: NSMutableData) throws -> NSMutableData
}

public enum MsgPackError: ErrorType {
    case NonUTF8StringValue(String)
    case UnsupportedValue(Any)
    case ValueTooLong(Any)
    case NotEnoughData
}


extension NSData {

    public func unpack() throws -> MsgPackValueType {
        var generator = NSDataByteGenerator(data: self)
        return try unpack(&generator)
    }

}

private extension NSData {

    func unpack<G: GeneratorType where G.Element == UInt8>(inout generator: G) throws -> MsgPackValueType {
        guard let type = generator.next() else { throw MsgPackError.NotEnoughData }

        switch type {

        // positive fixint
        case 0x00...0x7f:
            return type

        // negative fixint
        case 0xe0..<0xff, 0xff:
            return Int8(bitPattern: type)

        // fixmap

        // fixarray

        // fixstr
        case 0xa0...0xbf:
            let length = Int(type - 0xa0)
            return try String.unpack(&generator, length: length)

        // nil
        case 0xc0:
            return NSNull()

        // false
        case 0xc2:
            return false

        // true
        case 0xc3:
            return true

        // bin8
        case 0xc4:
            let length = try UInt8.unpack(&generator)
            return try NSData.unpack(&generator, length: Int(length))

        // bin16
        case 0xc5:
            let length = try UInt16.unpack(&generator)
            return try NSData.unpack(&generator, length: Int(length))

        // bin32
        case 0xc6:
            let length = try UInt32.unpack(&generator)
            return try NSData.unpack(&generator, length: Int(length))

        // ext8

        // ext16

        // ext32

        // float32
        case 0xca:
            return try Float.unpack(&generator)

        // float64
        case 0xcb:
            return try Double.unpack(&generator)

        // uint8
        case 0xcc:
            return try UInt8.unpack(&generator)

        // uint16
        case 0xcd:
            return try UInt16.unpack(&generator)

        // uint32
        case 0xce:
            return try UInt32.unpack(&generator)

        // uint64
        case 0xcf:
            return try UInt64.unpack(&generator)

        // int8
        case 0xd0:
            return try Int8.unpack(&generator)

        // int16
        case 0xd1:
            return try Int16.unpack(&generator)

        // int32
        case 0xd2:
            return try Int32.unpack(&generator)

        // int64
        case 0xd3:
            return try Int64.unpack(&generator)

        // fixext family

        // str8
        case 0xd9:
            let length = try UInt8.unpack(&generator)
            return try String.unpack(&generator, length: Int(length))

        // str16
        case 0xd9:
            let length = try UInt16.unpack(&generator)
            return try String.unpack(&generator, length: Int(length))

        // str32
        case 0xd9:
            let length = try UInt32.unpack(&generator)
            return try String.unpack(&generator, length: Int(length))

        // array16

        // array32

        // map16

        // map32

        default:
            throw MsgPackError.UnsupportedValue(type)
        }
    }

}