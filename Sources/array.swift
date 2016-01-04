//
// Implementation of msgpack array family format.
//  https://github.com/msgpack/msgpack/blob/master/spec.md#formats-array
//
import Foundation


extension Array: MsgPackValueType {

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
            if let item = object as? MsgPackValueType {
                try item.pack(data)
            } else {
                throw MsgPackError.UnsupportedValue(object)
            }
        }
        return data
    }

}
