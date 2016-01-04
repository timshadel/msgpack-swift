import Foundation


// MARK: - Main Types

public protocol MsgPackValueType {
    func pack(data: NSMutableData) throws -> NSMutableData
    static func unpack(data: NSData) throws -> MsgPackValueType
}

public enum MsgPackError: ErrorType {
    case NonUTF8StringValue(String)
    case UnsupportedValue(Any)
    case ValueTooLong(Any)
}
