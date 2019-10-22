//
//  Copyright © 2019 dc. All rights reserved.
//

import Combine
import Foundation

// MARK: - ReplayService

struct ReplayService {

  // MARK: Lifecycle

  init(userID: String, session: URLSession = .shared, decoder: JSONDecoder = .init()) {
    self.userID = userID
    self.session = session
    self.decoder = decoder

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    decoder.dateDecodingStrategy = .formatted(formatter)
  }

  // MARK: Internal

  func replayList() -> AnyPublisher<[ReplayInfo], Error> {
    session
      .dataTaskPublisher(for: NetworkPath.replayList(userID: userID).url)
      .map { $0.data }
      .decode(type: ReplayList.self, decoder: decoder)
      .map { $0.replays }
      .eraseToAnyPublisher()
  }

  func getReplay(_ replayID: String) -> AnyPublisher<[File], Error> {
    return getMetadata(replayID: replayID)
      .map { metafile -> AnyPublisher<[File], Error> in
        let metadata = try! self.decoder.decode(ReplayMetadata.self, from: metafile.data)
        var filePublishers: [AnyPublisher<File, Error>] = []
        for x in 0..<metadata.chunks {
          filePublishers.append(self.getChunk(replayID: replayID, chunkID: x))
        }

        let metaPublisher = Just(metafile)
          .setFailureType(to: Error.self)
          .eraseToAnyPublisher()
        filePublishers.append(metaPublisher)

        filePublishers.append(self.getHeader(replayID: replayID))

        return Publishers
          .MergeMany(filePublishers)
          .collect()
          .eraseToAnyPublisher()
      }
      .flatMap { $0 }
      .eraseToAnyPublisher()
  }

  // MARK: Private

  private let userID: String
  private let session: URLSession
  private let decoder: JSONDecoder

  private func getMetadata(replayID: String) -> AnyPublisher<File, Error> {
    return session
      .dataTaskPublisher(for: NetworkPath.replay(replayID, userID: userID).urlRequest)
      .map { File(directoryName: nil, fileName: "startDownload", data: $0.data) }
      .mapError { $0 as Error }
      .eraseToAnyPublisher()
  }

  private func getChunk(replayID: String, chunkID: Int) -> AnyPublisher<File, Error> {
    return session
      .dataTaskPublisher(for: NetworkPath.chunk(replayID, chunkID: chunkID).urlRequest)
      .map { File(directoryName: "file", fileName: "chunk.\(chunkID)", data: $0.data) }
      .mapError { $0 as Error }
      .eraseToAnyPublisher()
  }

  private func getHeader(replayID: String) -> AnyPublisher<File, Error> {
    return session
      .dataTaskPublisher(for: NetworkPath.header(replayID).urlRequest)
      .map { File(directoryName: "file", fileName: "replay.header", data: $0.data) }
      .mapError { $0 as Error }
      .eraseToAnyPublisher()
  }
}

// MARK: - File

struct File {
  let directoryName: String?
  let fileName: String
  let data: Data
}
