import SwiftUI
import CoreData

struct CircularProgressView: View {
  let progress: Double
  
  var body: some View {
    ZStack {
      Circle()
        .stroke(
          Color.blue.opacity(0.2),
          lineWidth: 3
        )
      Circle()
        .trim(from: 0, to: progress)
        .stroke(
          Color.blue,
          style: StrokeStyle(
            lineWidth: 3,
            lineCap: .round
          )
        )
        .rotationEffect(.degrees(-90))
    }
  }
}

struct CircularProgressView_Previews: PreviewProvider {
  static var previews: some View {
    CircularProgressView(progress: 0.33).previewInterfaceOrientation(.portraitUpsideDown)
  }
}
