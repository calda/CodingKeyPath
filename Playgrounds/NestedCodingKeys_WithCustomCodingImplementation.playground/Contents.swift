import Foundation

// MARK: - JSON Payload

let json = """
{
    "id": "SE-0274",
    "title": "Concise magic file names",
    "metadata": {
        "review_start_date": "2020-01-08T00:00:00Z",
        "review_end_date": "2020-01-16T00:00:00Z"
    }
}
"""

// MARK: - Codable type (using a custom Codable implementation)

struct EvolutionProposal: Codable {
    
    var id: String
    var title: String
    var reviewStartDate: Date
    var reviewEndDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case metadata
        
        enum MetadataCodingKeys: String, CodingKey {
            case reviewStartDate
            case reviewEndDate
        }
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        let metadataContainer = try rootContainer.nestedContainer(keyedBy: CodingKeys.MetadataCodingKeys.self, forKey: .metadata)
        
        id = try rootContainer.decode(String.self, forKey: .id)
        title = try rootContainer.decode(String.self, forKey: .title)
        reviewStartDate = try metadataContainer.decode(Date.self, forKey: .reviewStartDate)
        reviewEndDate = try metadataContainer.decode(Date.self, forKey: .reviewEndDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var rootContainer = encoder.container(keyedBy: CodingKeys.self)
        var metadataContainer = rootContainer.nestedContainer(keyedBy: CodingKeys.MetadataCodingKeys.self, forKey: .metadata)
        
        try rootContainer.encode(id, forKey: .id)
        try rootContainer.encode(title, forKey: .title)
        try metadataContainer.encode(reviewStartDate, forKey: .reviewStartDate)
        try metadataContainer.encode(reviewEndDate, forKey: .reviewEndDate)
    }
    
}

// MARK: Decoding

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
decoder.keyDecodingStrategy = .convertFromSnakeCase
try decoder.decode(EvolutionProposal.self, from: Data(json.utf8))
