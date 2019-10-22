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
      .assign(to: \.replays, on: self)
  }

  func getReplay(replayID: String) {
    replayFetch = replayService
      .getReplay(replayID)
      .sink(receiveCompletion: { completion in
        print("Finished downloading.")
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
  private var replays: [ReplayInfo] = [] {
    didSet {
      printList()
    }
  }
  private var lastUserInput: String? = nil {
    didSet {
      handleInput()
    }
  }

  private func printList() {
    for (index, replay) in replays.enumerated() {
      print("\(index)\t\(replay.date)\t\(replay.map)")
    }
    print("Enter # to download...")
    lastUserInput = readLine(strippingNewline: true)
  }

  private func handleInput() {
    guard
      let lastUserInput = lastUserInput,
      let asInteger = Int(lastUserInput),
      let replay = replays[safe: asInteger] else
    {
      return
    }

    getReplay(replayID: replay.replayID)
  }

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

public extension Collection {
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
