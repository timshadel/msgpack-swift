//
// Implementation of msgpack str family format.
//  https://github.com/msgpack/msgpack/blob/master/spec.md#formats-str
//
import Foundation


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

    public static func unpack(data: NSData) throws -> MsgPackValueType {
        var type: UInt8 = 0
        data.getBytes(&type, length: 1)

        var start = 1
        var length = 0
        if type >= 0b10100000 && type < 0b11000000 {
            length = Int(type) - Int(0b10100000)
            guard data.length == length + 1 else { throw MsgPackError.UnsupportedValue(data) }
        } else if type == 0xd9 {
            start = 2
            var value: UInt8 = 0
            data.getBytes(&value, range: NSMakeRange(1, 1))
            length = Int(value)
            guard data.length == length + 2 else { throw MsgPackError.UnsupportedValue(data) }
        } else if type == 0xda {
            start = 3
            var value: UInt16 = 0
            data.getBytes(&value, range: NSMakeRange(1, 2))
            length = Int(CFSwapInt16BigToHost(value))
            guard data.length == length + 3 else { throw MsgPackError.UnsupportedValue(data) }
        } else if type == 0xdb {
            start = 5
            var value: UInt32 = 0
            data.getBytes(&value, range: NSMakeRange(1, 4))
            length = Int(CFSwapInt32BigToHost(value))
            guard data.length == length + 5 else { throw MsgPackError.UnsupportedValue(data) }
        } else {
            throw MsgPackError.UnsupportedValue(data)
        }

        let stringData = data.subdataWithRange(NSMakeRange(start, length))
        guard let value = String(data: stringData, encoding: NSUTF8StringEncoding) else { throw MsgPackError.UnsupportedValue(data) }
        return value
    }

}
