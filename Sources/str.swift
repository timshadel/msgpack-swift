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

}
