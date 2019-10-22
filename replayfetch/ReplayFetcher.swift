//
//  Copyright © 2019 dc. All rights reserved.
//

import Foundation
import Combine

final class ReplayFetcher {

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

  private var replayListFetch: AnyCancellable? = nil
  private var replayFetch: AnyCancellable? = nil

  private func store(files: [File], for replayID: String) {
    let fm = FileManager()
    let replayPath = fm.currentDirectoryPath + "/" + replayID
    do {
      try fm.createDirectory(atPath: replayPath, withIntermediateDirectories: false, attributes: nil)
      try files.forEach { file in
        let filePath: String
        if let subdirectory = file.directoryName {
          let subdirectoryPath = replayPath + "/" + subdirectory
          try fm.createDirectory(atPath: subdirectoryPath, withIntermediateDirectories: true, attributes: nil)
          filePath = subdirectoryPath + "/" + file.fileName
        } else {
          filePath = replayPath.appending("/" + file.fileName)
        }
        fm.createFile(atPath: filePath, contents: file.data, attributes: nil)
      }
      exit(0)
    } catch {
      print("Fuck: \(error)")
    }
  }
}
