import Foundation

// MARK: - JSON Payload

let json = """
{
    "id": "SE-0274",
    "title": "Concise magic file names",
    "metadata": {
        "review_start_date": "2020-01-08T00:00:00Z",
        "review_end_date": "2020-01-16T00:00:00Z"
    }}
"""

// MARK: - Codable type (proxying to Codable subtypes)

struct EvolutionProposal: Codable {
    
    var id: String
    var title: String
  
    var reviewStartDate: Date {
        get { metadata.reviewStartDate }
        set { metadata.reviewStartDate = newValue }
    }
  
    var reviewEndDate: Date {
        get { metadata.reviewEndDate }
        set { metadata.reviewEndDate = newValue }
    }
  
    init(
        id: String,
        title: String,
        reviewStartDate: Date,
        reviewEndDate: Date)
    {
        self.id = id
        self.title = title
        metadata = Metadata(
          reviewStartDate: reviewStartDate,
          reviewEndDate: reviewEndDate)
    }

    private var metadata: Metadata
  
    private struct Metadata: Codable {
        var reviewStartDate: Date
        var reviewEndDate: Date
    }
  
}

// MARK: Decoding

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
decoder.keyDecodingStrategy = .convertFromSnakeCase
try decoder.decode(EvolutionProposal.self, from: Data(json.utf8))
