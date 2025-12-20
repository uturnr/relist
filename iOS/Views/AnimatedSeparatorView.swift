import SwiftUI

enum AnimatedSeparatorViewStyle {
  case navBar
  case taskItem
}

private func getColor(_ style: AnimatedSeparatorViewStyle) -> Color {
  switch style {
  case .navBar:
    return .systemBackground.blend(.blue, intensity: 0.8)
  case .taskItem:
    return .primary.opacity(0.4)
  }
}

/// Use conditional logic to start animation, Use .id() modifier to restart
/// animation. Animation is played during delay before removal of items from
/// list when the app is configured to hide completed tasks.
struct AnimatedSeparatorView: View {
  var style: AnimatedSeparatorViewStyle
  /// Animation restarts if this value changes
  var key: TimeInterval
  var show = true
  /// The parent should use the key to determine if this is the latest
  /// animation and therefore whether to take action upon animation end.
  var closureWithKey: ((_ key: TimeInterval) -> Void)?
  let duration = 1.0

  @State private var widthRatio: CGFloat = 0.0
  
  var body: some View {
    GeometryReader { metrics in
      VStack(spacing: 0) {
        ZStack {
          Rectangle()
            .fill(Color.systemGray5)
            .frame(width: metrics.size.width, height: 1)
          if (show) {
            Rectangle()
              .fill(getColor(style))
              .frame(width: metrics.size.width * widthRatio, height: 1)
              .animation(
                Animation.linear(duration: duration), value: widthRatio
              )
              .onAppear {
                widthRatio = 0.0
                widthRatio = 1.0
                
                guard let closureTest = closureWithKey else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                  closureTest(key)
                }
              }
              .frame(
                maxWidth: .infinity,
                alignment: .bottomTrailing
              )
          }
        }
      }.frame(
        maxWidth: .infinity,
        alignment: .bottomTrailing
      )
    }.frame(height: 1)
  }
}
