import Foundation

enum AppSettings {
  static private let displayNameKey = "DisplayName"
  static var displayName: String {
    get {
      // swiftlint:disable:next force_unwrapping
//      return UserDefaults.standard.string(forKey: displayNameKey)!
        return UserDefaults.standard.string(forKey: displayNameKey) ?? "Default Name"

    }
    set {
      UserDefaults.standard.set(newValue, forKey: displayNameKey)
    }
  }
}
