//
// Implementation of msgpack bin family format.
//  https://github.com/msgpack/msgpack/blob/master/spec.md#formats-bin
//
import Foundation

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

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(data)
    }

    public func unpack() throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(self)
    }

}
