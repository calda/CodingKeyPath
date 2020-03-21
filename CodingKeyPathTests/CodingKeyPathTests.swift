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
    
    /// The compiler will auto-synthesize this:
    func encode(to encoder: Encoder) throws {
        try encoder.encode(id, forKeyPath: CodingKeyPaths.id)
        try encoder.encode(title, forKeyPath: CodingKeyPaths.title)
        try encoder.encode(reviewStartDate, forKeyPath: CodingKeyPaths.reviewStartDate)
        try encoder.encode(reviewEndDate, forKeyPath: CodingKeyPaths.reviewEndDate)
    }
    
    /// The compiler will auto-synthesize this:
    init(from decoder: Decoder) throws {
        id = try decoder.decode(String.self, forKeyPath: CodingKeyPaths.id)
        title = try decoder.decode(String.self, forKeyPath: CodingKeyPaths.title)
        reviewStartDate = try decoder.decode(Date.self, forKeyPath: CodingKeyPaths.reviewStartDate)
        reviewEndDate = try decoder.decode(Date.self, forKeyPath: CodingKeyPaths.reviewEndDate)
    }
}

// MARK: Tests

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
