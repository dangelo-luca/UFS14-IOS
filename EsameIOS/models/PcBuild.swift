//
//  PcBuild.swift
//  EsameIOS
//
//  Created by s6 on 13/10/26.
//

import Foundation

class PcBuild {
    var os : Os!;
    var cpu: CPU!;
    var cpu_fan: CPU_Fan!;
    var harddrive: HardDrive!;
    var motherboard: Motherboard!;
    var pc_case: Case!;
    var psu: PSU!;
    var ram: RAM!;
    var soundcard: SoundCard!;
    var gpu: VideoCard!;
    var wificard: WirelessNetworkCard!;
    
    init(os: Os!, cpu: CPU!, cpu_fan: CPU_Fan!, harddrive: HardDrive!, motherboard: Motherboard!, pc_case: Case!, psu: PSU!, ram: RAM!, soundcard: SoundCard!, gpu: VideoCard!, wificard: WirelessNetworkCard!) {
        self.os = os
        self.cpu = cpu
        self.cpu_fan = cpu_fan
        self.harddrive = harddrive
        self.motherboard = motherboard
        self.pc_case = pc_case
        self.psu = psu
        self.ram = ram
        self.soundcard = soundcard
        self.gpu = gpu
        self.wificard = wificard
    }
}
