
# msgpack-swift

A Swift 2.2 package implementation of msgpack. [msgpack][msgpack] is a very fast, binary format similar in nature to JSON. It transforms basic native structures into raw bytes compactly, and predictibly. It has implementations in lots of languages, making it highly compatible between environments.

[msgpack]: http://msgpack.org

## Code Examples

### Basic

Pack:

```swift
let data = try "Hello, world!".pack(NSMutableData())
// => <ad48656c 6c6f2c20 776f726c 6421>
```

## Core Decisions

### Swift Package

To best support widespread reuse for Swift 2.2+, we've created a Swift Package. For now that means we have no standard way of using tests, but that will come as the Package spec matures.

### Protocol Based

### License

MIT.
