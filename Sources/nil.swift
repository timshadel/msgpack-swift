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

}
