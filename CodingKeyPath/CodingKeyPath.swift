
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

// MARK: - KeyPathEncodingContainer

public struct KeyPathEncodingContainer<K: CodingKeyPath> {
    
    public mutating func encode<T>(_ value: T, forKeyPath keyPath: K) throws where T: Encodable {
        try underlyingContainer.encode(value, forKeyPath: keyPath)
    }
    
    public mutating func encodeIfPresent<T>(_ value: T?, forKeyPath keyPath: K) throws where T: Encodable {
        try underlyingContainer.encodeIfPresent(value, forKeyPath: keyPath)
    }
    
    private var underlyingContainer: KeyedEncodingContainer<_CodingKeyPathComponent>
    
    init(wrapping underlyingContainer: KeyedEncodingContainer<_CodingKeyPathComponent>) {
        self.underlyingContainer = underlyingContainer
    }
    
}

public extension Encoder {
    func keyPathContainer<KeyPath>(keyedBy type: KeyPath.Type)
        -> KeyPathEncodingContainer<KeyPath> where KeyPath: CodingKeyPath
    {
        KeyPathEncodingContainer<KeyPath>(wrapping: container(keyedBy: _CodingKeyPathComponent.self))
    }
}

public extension KeyedEncodingContainer {
    mutating func nestedKeyPathContainer<KeyPath>(keyedBy type: KeyPath.Type, forKey key: Key) throws
        -> KeyPathEncodingContainer<KeyPath> where KeyPath: CodingKeyPath
    {
        KeyPathEncodingContainer<KeyPath>(wrapping: nestedContainer(keyedBy: _CodingKeyPathComponent.self, forKey: key))
    }
}

public extension UnkeyedEncodingContainer {
    mutating func nestedKeyPathContainer<KeyPath>(keyedBy type: KeyPath.Type) throws
        -> KeyPathEncodingContainer<KeyPath> where KeyPath: CodingKeyPath
    {
        KeyPathEncodingContainer<KeyPath>(wrapping: nestedContainer(keyedBy: _CodingKeyPathComponent.self))
    }
}

// MARK: - KeyPathDecodingContainer

public struct KeyPathDecodingContainer<K> where K: CodingKeyPath {
    
    public func decode<T>(_ type: T.Type, forKeyPath keyPath: K) throws -> T where T: Decodable {
        try underlyingContainer.decode(T.self, forKeyPath: keyPath)
    }
    
    public func decodeIfPresent<T>(_ type: T.Type, forKeyPath keyPath: K) throws -> T? where T: Decodable {
        try underlyingContainer.decodeIfPresent(T.self, forKeyPath: keyPath)
    }
    
    private var underlyingContainer: KeyedDecodingContainer<_CodingKeyPathComponent>
    
    init(wrapping underlyingContainer: KeyedDecodingContainer<_CodingKeyPathComponent>) {
        self.underlyingContainer = underlyingContainer
    }
    
}

public extension Decoder {
    func keyPathContainer<KeyPath>(keyedBy type: KeyPath.Type) throws
        -> KeyPathDecodingContainer<KeyPath> where KeyPath: CodingKeyPath
    {
        try KeyPathDecodingContainer(wrapping: self.container(keyedBy: _CodingKeyPathComponent.self))
    }
}

public extension KeyedDecodingContainer {
    mutating func nestedKeyPathContainer<KeyPath>(keyedBy type: KeyPath.Type, forKey key: Key) throws
        -> KeyPathDecodingContainer<KeyPath> where KeyPath: CodingKeyPath
    {
        try KeyPathDecodingContainer(wrapping: nestedContainer(keyedBy: _CodingKeyPathComponent.self, forKey: key))
    }
}

public extension UnkeyedDecodingContainer {
    mutating func nestedKeyPathContainer<KeyPath>(keyedBy type: KeyPath.Type) throws
        -> KeyPathDecodingContainer<KeyPath> where KeyPath: CodingKeyPath
    {
        try KeyPathDecodingContainer(wrapping: nestedContainer(keyedBy: _CodingKeyPathComponent.self))
    }
}


