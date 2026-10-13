//
//  PcBuild.swift
//  EsameIOS
//
//  Created by s6 on 13/10/26.
//

import Foundation

class PcBuild {
    var OS : Os!;
    var CPU: CPU!;
    var CPU_Fan: CPU_Fan!;
    
    init(OS: Os!, CPU: CPU!, CPU_Fan: CPU_Fan!) {
        self.OS = OS
        self.CPU = CPU
        self.CPU_Fan = CPU_Fan
    }
}
