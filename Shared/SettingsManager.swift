import Foundation

final class SettingsManager: ObservableObject {
  @propertyWrapper
  struct CloudSetting<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
      get {
        NSUbiquitousKeyValueStore.default.object(forKey: key) as? T ?? defaultValue
      }
      set {
        NSUbiquitousKeyValueStore.default.set(newValue, forKey: key)
        NSUbiquitousKeyValueStore.default.synchronize()
      }
    }
    
    init(_ key: String, default: T) {
      self.key = key
      self.defaultValue = `default`
    }
  }
  
  static let shared = SettingsManager()
  
  @CloudSetting("showTaskIndices", default: false)
  var showTaskIndices: Bool
}
