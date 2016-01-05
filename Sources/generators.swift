import Foundation


struct NSDataByteGenerator: GeneratorType {

    let data: NSData
    var i: Int = 0

    init(data: NSData) {
        self.data = data
    }

    mutating func next() -> UInt8? {
        if i >= data.length {
            return nil
        }

        var value: UInt8 = 0
        data.getBytes(&value, range: NSMakeRange(i, 1))
        i += 1

        return value
    }

}
