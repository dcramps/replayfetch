//
//  Copyright © 2019 dc. All rights reserved.
//

import Foundation

// MARK: - ReplayList

struct ReplayList: Decodable {
  let replays: [ReplayInfo]
}

// MARK: - ReplayInfo

struct ReplayInfo: Decodable {
  let replayID: String
  let isLive: Bool
  let map: String
  let date: Date
  let size: Int
  let length: TimeInterval

  enum CodingKeys: String, CodingKey {
    case replayID = "SessionName"
    case isLive = "bIsLive"
    case map = "FriendlyName"
    case date = "Timestamp"
    case size = "SizeInBytes"
    case length = "DemoTimeInMS"
  }
}
