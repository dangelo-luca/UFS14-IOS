import SwiftUI

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    @Published var opzioni = Options()
    
    @Published var user_id: String {
        didSet {
            UserDefaults.standard.set(user_id, forKey: "user_id")
        }
    }
    
    @Published var psw_hash: String {
        didSet {
            UserDefaults.standard.set(psw_hash, forKey: "psw_hash")
        }
    }
    
    var isLogged: Bool {
        !user_id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !psw_hash.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private init() {
        self.user_id = UserDefaults.standard.string(forKey: "user_id") ?? ""
        self.psw_hash = UserDefaults.standard.string(forKey: "psw_hash") ?? ""
    }
}

struct Options {
    @AppStorage("theme") var theme = "auto"
    var themesAvaiable = ["auto", "light", "dark"]
    
    func getTheme() -> ColorScheme? {
        switch theme {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil // 'nil' affida a SwiftUI la gestione automatica del tema di sistema
        }
    }
}
