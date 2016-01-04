//
// Implementation of msgpack bin family format.
//  https://github.com/msgpack/msgpack/blob/master/spec.md#formats-bin
//
import Foundation


extension Bool: MsgPackValueType {

    public func pack(data: NSMutableData) -> NSMutableData {
        var value = self ? 0xc3 : 0xc2
        data.appendBytes(&value, length: 1)
        return data
    }

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        guard data.length == 1 else { throw MsgPackError.UnsupportedValue(data) }

        var bytes: UInt8 = 0
        data.getBytes(&bytes, length: 1)
        if bytes == 0xc3 {
            return true
        } else if bytes == 0xc2 {
            return false
        } else {
            throw MsgPackError.UnsupportedValue(data)
        }
    }

}
