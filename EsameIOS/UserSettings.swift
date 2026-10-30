//
//  UserSettings.swift
//  EsameIOS
//
//  Created by s6 on 30/10/26.
//

import Foundation
import SwiftUICore
import SwiftUI

class UserSettings : ObservableObject {
    static var shared = UserSettings()
    @Published var opzioni = Options()
    @AppStorage("user_id") var user_id = ""
    
    private init(){
        if(user_id != ""){
            
        }
    }
}

struct Options {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("theme") var theme = "auto"
    var themesAvaiable = ["auto", "light", "dark"]
    
    func getTheme() -> ColorScheme {
        switch theme {
            case "light": return .light
            case "dark":  return .dark
            default:  return colorScheme
            }
    }
}
