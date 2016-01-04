//
// Implementation of msgpack nil family format.
//  https://github.com/msgpack/msgpack/blob/master/spec.md#formats-nil
//
import Foundation


extension NSNull: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var value = 0xc0
        data.appendBytes(&value, length: 1)
        return data
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        guard data.length == 1 else { throw MsgPackError.UnsupportedValue(data) }

        var bytes: UInt8 = 0
        data.getBytes(&bytes, length: 1)
        guard bytes == 0xc0 else { throw MsgPackError.UnsupportedValue(data) }

        return NSNull()
    }

}
