//
//  UserSettings.swift
//  EsameIOS
//
//  Created by s6 on 30/10/26.
//

import Foundation

class UserSettings : ObservableObject {
    static var shared = UserSettings()
    @Published var opzioni = Options()
    
    private init(){
        
    }
}

struct Options {
    var theme = "auto"
    var themesAvaiable = ["auto", "light", "dark"]
}
