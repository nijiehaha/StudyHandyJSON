import HandyJSON

/// test class
class Human {
    var age: Int = 0
    /// from HandyJSON
    func headPointerOfClass() -> UnsafeMutablePointer<Int8> {
        let opaquePointer = Unmanaged.passUnretained(self as AnyObject).toOpaque()
        let mutableTypedPointer = opaquePointer.bindMemory(to: Int8.self, capacity: MemoryLayout<Human>.stride)
        return UnsafeMutablePointer<Int8>(mutableTypedPointer)
    }
}

/// from HandyJSON
var is64BitPlatform: Bool {
    return MemoryLayout<Int>.size == MemoryLayout<Int64>.size
}

/// from HandyJSON
var contextDescriptorOffsetLocation: Int {
    return is64BitPlatform ? 8 : 11
}

/// test
let human = Human()
let intFromJson = 1000

/// human Heap void * pointer
let humanRawPtr = UnsafeMutableRawPointer(human.headPointerOfClass())

let humanAgePtr =  humanRawPtr.advanced(by: contextDescriptorOffsetLocation + MemoryLayout<Int>.size).assumingMemoryBound(to: Int.self)
print(human.age)

/// write
humanAgePtr.initialize(to: intFromJson)
print(human.age)
    
print(MemoryLayout<Int>.size)


class BaseResponse<T: HandyJSON>: HandyJSON {
    var code: Int?
    var data: T?
    required init() {}
}

struct SampleData: HandyJSON {
    var id: Int?
}

let sample = SampleData(id: 2)
let resp = BaseResponse<SampleData>()
resp.code = 200
resp.data = sample
    
/// 从对象实例转换到JSON字符串
let jsonString = resp.toJSONString()!
print(jsonString)
    
/// 从字符串转换为对象实例
if let mappedObject = JSONDeserializer<BaseResponse<SampleData>>.deserializeFrom(json: jsonString) {
    print(mappedObject.data!.id!)
}
