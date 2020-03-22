
// MARK: - _CodingKeyPathComponent

struct _CodingKeyPathComponent: CodingKey {
    public let stringValue: String
    public let intValue: Int? = nil
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        return nil
    }
    
    init(codingKeyValue: CodingKey) {
        self.stringValue = codingKeyValue.stringValue
    }
}

extension CodingKeyPath {
    var _components: [_CodingKeyPathComponent] {
        if let existingKeyPathComponents = components as? [_CodingKeyPathComponent] {
            return existingKeyPathComponents
        } else {
            return components.map { _CodingKeyPathComponent(codingKeyValue: $0) }
        }
    }
}

private struct _CodingKeyPathComponents: CodingKeyPath {
    var components: [CodingKey]
    
    init(_ components: [CodingKey]) {
        self.components = components
    }
}

// MARK: KeyedEncodingContainer<_CodingKeyPathComponent>

extension KeyedEncodingContainer where K == _CodingKeyPathComponent {
    
    mutating func encode<T: Encodable>(_ value: T, forKeyPath keyPath: CodingKeyPath) throws {
        let keyPathComponents = keyPath._components
        
        if keyPathComponents.isEmpty {
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: codingPath + keyPath.components,
                    debugDescription: "Invalid CodingKeyPath. Components must not be empty."))
        }
        
        else if keyPathComponents.count == 1 {
            try self.encode(value, forKey: keyPathComponents[0])
        }
        
        else {
            var container = nestedContainer(keyedBy: _CodingKeyPathComponent.self, forKey: keyPathComponents[0])
            try container.encode(value, forKeyPath: _CodingKeyPathComponents(Array(keyPathComponents.dropFirst())))
        }
    }
    
    mutating func encodeIfPresent<T: Encodable>(_ value: T?, forKeyPath keyPath: CodingKeyPath) throws {
        if let value = value {
            try encode(value, forKeyPath: keyPath)
        }
    }
    
}

// MARK: KeyedDecodingContainer<_CodingKeyPathComponent>

extension KeyedDecodingContainer where K == _CodingKeyPathComponent {
    
    func decode<T: Decodable>(_ type: T.Type, forKeyPath keyPath: CodingKeyPath) throws -> T {
        if let value = try decodeIfPresent(T.self, forKeyPath: keyPath) {
            return value
        } else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(
                codingPath: self.codingPath + keyPath.components,
                debugDescription: "Value not found."))
        }
    }
    
    func decodeIfPresent<T: Decodable>(_ type: T.Type, forKeyPath keyPath: CodingKeyPath) throws -> T? {
        let keyPathComponents = keyPath._components
        
        if keyPathComponents.isEmpty {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: self.codingPath + keyPath.components,
                debugDescription: "Invalid CodingKeyPath. Components must not be empty."))
        }
        
        else if keyPathComponents.count == 1 {
            return try decodeIfPresent(T.self, forKey: keyPathComponents[0])
        }
        
        else {
            let container = try nestedContainer(keyedBy: _CodingKeyPathComponent.self, forKey: keyPathComponents[0])
            return try container.decodeIfPresent(T.self, forKeyPath: _CodingKeyPathComponents(Array(keyPathComponents.dropFirst())))
        }
    }
    
}

