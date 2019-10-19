//
//  Copyright © 2019 dc. All rights reserved.
//

import Foundation

struct NetworkPath {
  let scheme: String
  let host: Host
  let path: String
  let queryItems: [URLQueryItem]

  var url: URL {
    var components = URLComponents()
    components.scheme = scheme
    components.host = host.rawValue
    components.path = path
    components.queryItems = queryItems

    return components.url!
  }
}

extension NetworkPath {
  static func replayList(userID: String) -> NetworkPath {
    let queryItems = [
      URLQueryItem(name: "app", value: "UnrealTournament"),
      URLQueryItem(name: "cl", value: "3525360"),
      URLQueryItem(name: "version", value: "2"),
      URLQueryItem(name: "user", value: userID),
    ]
    return NetworkPath(scheme: "https", host: .production, path: "/replay/v2/replay", queryItems: queryItems)
  }
}

enum Host: String {
  case production = "utreplay-public-service-prod10.ol.epicgames.com"
}
