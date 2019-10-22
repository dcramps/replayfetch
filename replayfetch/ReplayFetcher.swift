//
//  Copyright © 2019 dc. All rights reserved.
//

import Foundation
import Combine

// MARK: - ReplayFetcher

final class ReplayFetcher {

  // MARK: Lifecycle

  init(token: String, userID: String) {
    self.token = token
    self.userID = userID
    self.replayService = ReplayService(userID: userID)
  }

  // MARK: Internal

  func getList() {
    replayListFetch = replayService
      .replayList()
      .catch { _ in Just([]) }
      .sink(receiveValue: {
        $0.forEach {
          print("\($0.date): \($0.map)")
        }

        self.getReplay(replayID: $0.first!.replayID)
      })
  }

  func getReplay(replayID: String) {
    replayFetch = replayService
      .getReplay(replayID)
      .sink(receiveCompletion: { completion in
        print("Finished")
      }, receiveValue: { files in
        self.store(files: files, for: replayID)
      })
  }


  // MARK: Private

  private let replayService: ReplayService
  private let token: String
  private let userID: String
  private let fileManager = FileManager()

  private var replayListFetch: AnyCancellable? = nil
  private var replayFetch: AnyCancellable? = nil

  private func store(files: [File], for replayID: String) {
    do {
      try write(files: files, to: fileManager.currentDirectoryPath + "/" + replayID)
      exit(0)
    } catch {
      //TODO: Better error handling
      print("Fuck: \(error)")
      exit(1)
    }
  }

  private func write(files: [File], to replayPath: String) throws {
    try fileManager.createDirectory(atPath: replayPath, withIntermediateDirectories: false, attributes: nil)
    try files.forEach { file in
      let filePath: String
      if let subdirectory = file.directoryName {
        let subdirectoryPath = replayPath + "/" + subdirectory
        try fileManager.createDirectory(atPath: subdirectoryPath, withIntermediateDirectories: true, attributes: nil)
        filePath = subdirectoryPath + "/" + file.fileName
      } else {
        filePath = replayPath.appending("/" + file.fileName)
      }
      fileManager.createFile(atPath: filePath, contents: file.data, attributes: nil)
    }
  }
}
