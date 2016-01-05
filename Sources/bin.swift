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


    static func unpack<G: GeneratorType where G.Element == UInt8>(inout generator: G, length: Int) throws -> NSData {
        let data = NSMutableData(capacity: length)!
        for _ in 0..<length {
            var byte = generator.next()
            guard byte != nil else { throw MsgPackError.NotEnoughData }
            data.appendBytes(&byte, length: 1)
        }

        return data
    }

}
