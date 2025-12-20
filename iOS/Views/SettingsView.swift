import SwiftUI
import CloudKit

struct SettingsView: View {
  @StateObject private var settings = SettingsManager.shared
  @State private var cloudKitEnv: String = "Checking…"
  
  var body: some View {
    List {
      Section(header: Text("Dev")) {
        Toggle("Show Task Indices", isOn: $settings.showTaskIndices)
        HStack {
          Text("CloudKit Environment")
          Spacer()
          Text(
            (
              CKContainer.default()
                .containerIdentifier?.contains(".dev") ?? false
            ) ? "Development" : "Production"
          )
            .foregroundColor(.secondary)
        }
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
