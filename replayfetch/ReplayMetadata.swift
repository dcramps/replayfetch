//
//  Copyright © 2019 dc. All rights reserved.
//

import Foundation

// MARK: - ReplayState
enum ReplayState: String, Decodable {
  case final = "Final"
}

// MARK: - ReplayMetaData

struct ReplayMetadata: Decodable {
  let state: ReplayState
  let chunks: Int
  let time: TimeInterval
  let viewerID: String

  enum CodingKeys: String, CodingKey {
    case state
    case chunks = "numChunks"
    case time
    case viewerID = "viewerId"
  }
}
