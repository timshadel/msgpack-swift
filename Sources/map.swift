//
// Implementation of msgpack map family format.
//  https://github.com/msgpack/msgpack/blob/master/spec.md#formats-map
//
import Foundation


extension Dictionary: MsgPackValueType {

    public func pack(data: NSMutableData) throws -> NSMutableData {
        let length = self.count
        if length < 16 {
            var type = 0b10000000 + length
            data.appendBytes(&type, length: 1)
        } else if length <= Int(UInt16.max) {
            var type = 0xde
            var len = CFSwapInt16HostToBig(UInt16(length))
            data.appendBytes(&type, length: 1)
            data.appendBytes(&len, length: 2)
        } else if length <= Int(UInt32.max) {
            var type = 0xdf
            var len = CFSwapInt32HostToBig(UInt32(length))
            data.appendBytes(&type, length: 1)
            data.appendBytes(&len, length: 4)
        } else {
            throw MsgPackError.ValueTooLong(self)
        }
        for (k, v) in self {
            if let key = k as? MsgPackValueType {
                if let value = v as? MsgPackValueType {
                    try key.pack(data)
                    try value.pack(data)
                } else {
                    throw MsgPackError.UnsupportedValue(v)
                }
            } else {
                throw MsgPackError.UnsupportedValue(k)
            }
        }
        return data
    }

}
