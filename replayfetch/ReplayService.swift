//
//  Copyright © 2019 dc. All rights reserved.
//

import Combine
import Foundation

struct ReplayService {

  // MARK: Lifecycle

  init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
    self.session = session
    self.decoder = decoder

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    decoder.dateDecodingStrategy = .formatted(formatter)
  }

  // MARK: Internal

  func replayList(for userID: String) -> AnyPublisher<[ReplayMetadata], Error> {
    session
      .dataTaskPublisher(for: NetworkPath.replayList(userID: userID).url)
      .map { $0.data }
      .decode(type: ReplayMetadataContainer.self, decoder: decoder)
      .map { $0.replays }
      .eraseToAnyPublisher()
  }

  // MARK: Private

  private let session: URLSession
  private let decoder: JSONDecoder
}
