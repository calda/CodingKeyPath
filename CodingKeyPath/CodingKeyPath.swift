
import Foundation

// MARK: - CodingKeyPath

public protocol CodingKeyPath {
    var components: [CodingKey] { get }
}

public extension CodingKeyPath where Self: RawRepresentable, RawValue == String {
    var components: [CodingKey] {
        rawValue
            .components(separatedBy: ".")
            .map { stringComponent in
                if let intComponent = Int(stringComponent) {
                    return _CodingKeyPathComponent(intValue: intComponent)
                } else {
                    return _CodingKeyPathComponent(stringValue: stringComponent)
                }
        }
    }
}

// MARK: - _CodingKeyPathComponent

private struct _CodingKeyPathComponent: CodingKey {
    public let intValue: Int?
    public let stringValue: String
    
    init(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
    
    init(stringValue: String) {
        self.intValue = nil
        self.stringValue = stringValue
    }
    
    init(codingKeyValue: CodingKey) {
        if let intValue = codingKeyValue.intValue {
            self = _CodingKeyPathComponent(intValue: intValue)
        } else {
            self = _CodingKeyPathComponent(stringValue: codingKeyValue.stringValue)
        }
    }
}

private extension CodingKeyPath {
    var _components: [_CodingKeyPathComponent] {
        if let existingKeyPathComponents = components as? [_CodingKeyPathComponent] {
            return existingKeyPathComponents
        } else {
            return components.map { _CodingKeyPathComponent(codingKeyValue: $0) }
        }
    }
}

// MARK: Decoder + CodingKeyPath

extension Decoder {
    public func decode<T: Decodable>(_ type: T.Type, forKeyPath keyPath: CodingKeyPath) throws -> T {
        var currentNestedContainer = try self.container(keyedBy: _CodingKeyPathComponent.self)
        var currentKeyPathComponents = keyPath._components
        
        while currentKeyPathComponents.count > 1 {
            let currentKeyPathComponent = currentKeyPathComponents[0]
            currentKeyPathComponents = Array(currentKeyPathComponents[1...])
            currentNestedContainer = try currentNestedContainer.nestedContainer(keyedBy: _CodingKeyPathComponent.self, forKey: currentKeyPathComponent)
        }
        
        return try currentNestedContainer.decode(T.self, forKey: currentKeyPathComponents[0])
    }
}

// MARK: Encoder + CodingKeyPath

extension Encoder {
    public func encode<T: Encodable>(_ value: T, forKeyPath keyPath: CodingKeyPath) throws {
        guard keyPath.components.count > 0 else {
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: keyPath.components,
                    debugDescription: "Invalid CodingKeyPath. Path must not be empty."))
        }
        
        var currentNestedContainer = self.container(keyedBy: _CodingKeyPathComponent.self)
        var currentKeyPathComponents = keyPath._components
        
        while currentKeyPathComponents.count > 1 {
            let currentKeyPathComponent = currentKeyPathComponents[0]
            currentKeyPathComponents = Array(currentKeyPathComponents[1...])
            currentNestedContainer = currentNestedContainer.nestedContainer(keyedBy: _CodingKeyPathComponent.self, forKey: currentKeyPathComponent)
        }
        
        return try currentNestedContainer.encode(value, forKey: currentKeyPathComponents[0])
    }
}
