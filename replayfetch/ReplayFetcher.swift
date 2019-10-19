//
//  Copyright © 2019 dc. All rights reserved.
//

import Foundation
import Combine

final class ReplayFetcher {

  init(token: String, userID: String) {
    self.token = token
    self.userID = userID
  }

  // MARK: Internal

  func getList() {
    replayFetch = replayService
      .replayList(for: userID)
      .catch { e -> Just<[ReplayMetadata]> in
        print("Fuck: \(e)")
        return Just([])
      }
      .sink(receiveValue: {
        $0.forEach { print("\($0.date): \($0.map)") }
      })
  }

  func getReplay() {
    
  }


  // MARK: Private

  private let replayService = ReplayService()
  private let token: String
  private let userID: String

  private var replayFetch: AnyCancellable? = nil

}
