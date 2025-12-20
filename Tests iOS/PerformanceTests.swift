import XCTest

class PerformanceTests: BaseTestCase {
  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
      // This measures how long it takes to launch your application.
      // Skip in CI environments where performance can be unreliable
      guard ProcessInfo.processInfo.environment["CI"] == nil else {
        return
      }

      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }
}
