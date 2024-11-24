import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
  var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {

    #if canImport(UIKit)
    typealias NativeColor = UIColor
    #elseif canImport(AppKit)
    typealias NativeColor = NSColor
    #endif

    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var o: CGFloat = 0

    guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
      // TODO: handle failure
      return (0, 0, 0, 0)
    }

    return (r, g, b, o)
  }
}

// https://stackoverflow.com/a/64414674
extension Color {
  // MARK: - Text Colors
  static let lightText = Color(UIColor.lightText)
  static let darkText = Color(UIColor.darkText)
  static let placeholderText = Color(UIColor.placeholderText)

  // MARK: - Label Colors
  static let label = Color(UIColor.label)
  static let secondaryLabel = Color(UIColor.secondaryLabel)
  static let tertiaryLabel = Color(UIColor.tertiaryLabel)
  static let quaternaryLabel = Color(UIColor.quaternaryLabel)

  // MARK: - Background Colors
  static let systemBackground = Color(UIColor.systemBackground)
  static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
  static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
  
  // MARK: - Fill Colors
  static let systemFill = Color(UIColor.systemFill)
  static let secondarySystemFill = Color(UIColor.secondarySystemFill)
  static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
  static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)
  
  // MARK: - Grouped Background Colors
  static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
  static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
  static let tertiarySystemGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)
  
  // MARK: - Gray Colors
  static let systemGray = Color(UIColor.systemGray)
  static let systemGray2 = Color(UIColor.systemGray2)
  static let systemGray3 = Color(UIColor.systemGray3)
  static let systemGray4 = Color(UIColor.systemGray4)
  static let systemGray5 = Color(UIColor.systemGray5)
  static let systemGray6 = Color(UIColor.systemGray6)
  
  // MARK: - Other Colors
  static let separator = Color(UIColor.separator)
  static let opaqueSeparator = Color(UIColor.opaqueSeparator)
  static let link = Color(UIColor.link)
}

extension Color {
  func blend(_ color2: Color, intensity intensity2: CGFloat = 0.5) -> Color {
    let intensity1 = 1.0 - intensity2
    
    let color1 = self
    
    guard intensity1 > 0 else { return color2 }
    guard intensity2 > 0 else { return color1 }
    
    let color1Components = color1.components
    let color2Components = color2.components
    
    let (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (
      color1Components.red,
      color1Components.green,
      color1Components.blue,
      color1Components.opacity
    )
    let (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (
      color2Components.red,
      color2Components.green,
      color2Components.blue,
      color2Components.opacity
    )

    return Color(
      red: (intensity1 * r1) + (intensity2 * r2),
      green: (intensity1 * g1) + (intensity2 * g2),
      blue: (intensity1 * b1) + (intensity2 * b2),
      opacity: (intensity1 * a1) + (intensity2 * a2)
    )
  }
}
