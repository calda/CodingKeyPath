import XCTest
import CodingKeyPath

// MARK: - EvolutionProposal

struct EvolutionProposal: Codable {
    var id: String
    var title: String
    var reviewStartDate: Date
    var reviewEndDate: Date

    enum CodingKeyPaths: String, CodingKeyPath {
        case id
        case title
        case reviewStartDate = "metadata.reviewStartDate"
        case reviewEndDate = "metadata.reviewEndDate"
    }
    
    /// The compiler will auto-synthesize this:
    init(from decoder: Decoder) throws {
        let container = try decoder.keyPathContainer(keyedBy: CodingKeyPaths.self)
        id = try container.decode(String.self, forKeyPath: .id)
        title = try container.decode(String.self, forKeyPath: .title)
        reviewStartDate = try container.decode(Date.self, forKeyPath: .reviewStartDate)
        reviewEndDate = try container.decode(Date.self, forKeyPath: .reviewEndDate)
    }
    
    /// The compiler will auto-synthesize this:
    func encode(to encoder: Encoder) throws {
        var container = encoder.keyPathContainer(keyedBy: CodingKeyPaths.self)
        try container.encode(id, forKeyPath: .id)
        try container.encode(title, forKeyPath: .title)
        try container.encode(reviewStartDate, forKeyPath: .reviewStartDate)
        try container.encode(reviewEndDate, forKeyPath: .reviewEndDate)
    }
    
}

// MARK: Tests

extension EvolutionProposal {
    static let sampleJsonPayload = Data("""
    {
      "id" : "SE-0274",
      "title" : "Concise magic file names",
      "metadata" : {
        "review_start_date" : "2020-01-08T00:00:00Z",
        "review_end_date" : "2020-01-16T00:00:00Z"
      }
    }
    """.utf8)
}

class CodingKeyPathTests: XCTestCase {

    func testEvolutionProposalRoundtripDecodingAndEncoding() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decodedObject = try decoder.decode(EvolutionProposal.self, from: EvolutionProposal.sampleJsonPayload)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .prettyPrinted
        let reencodedPayload = try encoder.encode(decodedObject)
        
        XCTAssertEqual(reencodedPayload, EvolutionProposal.sampleJsonPayload)
    }

}
