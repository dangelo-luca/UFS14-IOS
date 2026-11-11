class PSU : Component {

    override class var categoria: TipoComponente { .psu }

    let type: String?
    let efficiency: String?
    let wattage: Double?
    let modular: String?
    let color: String?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Chiave.self)
        self.type = try container.decodeIfPresent(String.self, forKey: "type")
        self.efficiency = try container.decodeIfPresent(String.self, forKey: "efficiency")
        self.wattage = try container.decodeIfPresent(Double.self, forKey: "wattage")
        self.color = try container.decodeIfPresent(String.self, forKey: "color")

        if let testo = try? container.decodeIfPresent(String.self, forKey: "modular") {
            self.modular = testo
        } else if let booleano = try? container.decodeIfPresent(Bool.self, forKey: "modular") {
            self.modular = booleano ? "Sì" : "No"
        } else {
            self.modular = nil
        }
        try super.init(from: decoder)
    }

    override func getDetails() -> [String: Any] {
        var details = [String: Any]()

        details["Tipo"] = type ?? "N/A"
        details["Efficienza"] = efficiency ?? "N/A"
        details["Wattaggio"] = wattage != nil ? "\(Int(wattage!)) W" : "N/A"
        details["Modularità"] = modular ?? "N/A"
        details["Colore"] = color ?? "N/A"

        return details
    }
}
