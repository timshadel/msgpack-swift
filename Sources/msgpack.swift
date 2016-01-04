import Foundation


// MARK: - Main Types

public protocol MsgPackValueType {

    func pack(data: NSMutableData) throws -> NSMutableData

}

public enum MsgPackError: ErrorType {
    case NonUTF8StringValue(String)
    case UnsupportedValue(Any)
    case ValueTooLong(Any)
}
