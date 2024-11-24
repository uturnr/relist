import SwiftUI

extension Bundle {
  static var current: Bundle {
    class __ { }
    return Bundle(for: __.self)
  }
}
