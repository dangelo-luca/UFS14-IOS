import SwiftData
import Foundation

@Model
final class Build {
    @Attribute(.unique) var id: UUID
    var totalCost: Decimal
    var pcCase: String
    var cpu: String
    var cpuFan: String
    var hardDrive: String
    var motherboard: String
    var os: String
    var psu: String
    var ram: String
    var soundCard: String?
    var wirelessNetworkCard: String?

    // Riferimento all'utente proprietario
    var user: User?

    init(
        totalCost: Decimal,
        pcCase: String,
        cpu: String,
        cpuFan: String,
        hardDrive: String,
        motherboard: String,
        os: String,
        psu: String,
        ram: String,
        soundCard: String? = nil,
        wirelessNetworkCard: String? = nil,
        user: User? = nil
    ) {
        self.id = UUID()
        self.totalCost = totalCost
        self.pcCase = pcCase
        self.cpu = cpu
        self.cpuFan = cpuFan
        self.hardDrive = hardDrive
        self.motherboard = motherboard
        self.os = os
        self.psu = psu
        self.ram = ram
        self.soundCard = soundCard
        self.wirelessNetworkCard = wirelessNetworkCard
        self.user = user
    }
}