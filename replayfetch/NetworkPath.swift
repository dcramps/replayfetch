//
//  Copyright © 2019 dc. All rights reserved.
//

import Foundation

struct NetworkPath {
  let scheme: String
  let host: Host
  let path: String
  let queryItems: [URLQueryItem]
  let method: Method

  var url: URL {
    var components = URLComponents()
    components.scheme = scheme
    components.host = host.rawValue
    components.path = path
    components.queryItems = queryItems

    return components.url!
  }

  var urlRequest: URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue.uppercased()
    return request
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
    return NetworkPath(
      scheme: "https",
      host: .production,
      path: "/replay/v2/replay",
      queryItems: queryItems,
      method: .get)
  }

  static func replay(_ replayID: String, userID: String) -> NetworkPath {
    let queryItems = [
      URLQueryItem(name: "user", value: userID)
    ]

    return NetworkPath(
      scheme: "https",
      host: .production,
      path: "/replay/v2/replay/\(replayID)/startDownloading",
      queryItems: queryItems,
      method: .post)
  }

  static func chunk(_ replayID: String, chunkID: Int) -> NetworkPath {
    return NetworkPath(
      scheme: "https",
      host: .production,
      path: "/replay/v2/replay/\(replayID)/file/stream.\(chunkID)",
      queryItems: [],
      method: .get)
  }

  static func header(_ replayID: String) -> NetworkPath {
    return NetworkPath(
      scheme: "https",
      host: .production,
      path: "/replay/v2/replay/\(replayID)/file/replay.header",
      queryItems: [],
      method: .get)
  }
}

enum Host: String {
  case production = "utreplay-public-service-prod10.ol.epicgames.com"
}

enum Method: String {
  case get
  case post
}
