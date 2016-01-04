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
        var type: UInt8 = 0
        data.getBytes(&type, length: 1)

        var start = 1
        var length = 0
        if type == 0xc4 {
            start = 2
            var value: UInt8 = 0
            data.getBytes(&value, range: NSMakeRange(1, 1))
            length = Int(value)
            guard data.length == length + 2 else { throw MsgPackError.UnsupportedValue(data) }
        } else if type == 0xc5 {
            start = 3
            var value: UInt16 = 0
            data.getBytes(&value, range: NSMakeRange(1, 2))
            length = Int(CFSwapInt16BigToHost(value))
            guard data.length == length + 3 else { throw MsgPackError.UnsupportedValue(data) }
        } else if type == 0xc6 {
            start = 5
            var value: UInt32 = 0
            data.getBytes(&value, range: NSMakeRange(1, 4))
            length = Int(CFSwapInt32BigToHost(value))
            guard data.length == length + 5 else { throw MsgPackError.UnsupportedValue(data) }
        } else {
            throw MsgPackError.UnsupportedValue(data)
        }

        return data.subdataWithRange(NSMakeRange(start, length))
    }

    public func unpack() throws -> MsgPackValueType {
        throw MsgPackError.UnsupportedValue(self)
    }

}
