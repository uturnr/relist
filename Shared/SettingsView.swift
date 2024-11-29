import SwiftUI

struct SettingsView: View {
  @StateObject private var settings = SettingsManager.shared
  
  var body: some View {
    List {
      Section(header: Text("Dev")) {
        Toggle("Show Task Indices", isOn: $settings.showTaskIndices)
      }
    }
    .navigationTitle("Settings")
    .listStyle(InsetGroupedListStyle())
    .environment(\.defaultMinListRowHeight, 50)
    .tint(.accentColor)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      SettingsView()
    }
  }
}
