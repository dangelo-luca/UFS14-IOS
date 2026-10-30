//
//  RAM.swift
//  EsameIOS
//
class RAM : Component {

    override class var categoria: TipoComponente { .ram }

    let speed: [Double]       // [generazione DDR, MHz]; in rari casi è un solo numero
    let module: [Double]      // [numero moduli, GB per modulo]
    let color: String?
    let first_word_latency: Double?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Chiave.self)

        if let lista = try? container.decode([Double].self, forKey: "speed") {
            self.speed = lista
        } else {
            self.speed = [try container.decode(Double.self, forKey: "speed")]
        }

        // nel JSON la chiave si chiama "modules", non "module"
        self.module = try container.decode([Double].self, forKey: "modules")
        self.color = try container.decodeIfPresent(String.self, forKey: "color")
        self.first_word_latency = try container.decodeIfPresent(Double.self, forKey: "first_word_latency")
        try super.init(from: decoder)
    }

    override func getDetails() -> [String: Any] {
        var details = [String: Any]()

        if speed.count >= 2 {
            details["Tipo"] = "DDR\(Int(speed[0]))"
            details["Velocità"] = "\(Int(speed[1])) MHz"
        } else if let mhz = speed.first {
            details["Tipo"] = "N/A"
            details["Velocità"] = "\(Int(mhz)) MHz"
        }

        if module.count >= 2 {
            details["Capacità"] = "\(Int(module[0])) x \(Int(module[1])) GB"
        } else {
            details["Capacità"] = "N/A"
        }

        details["Colore"] = color ?? "N/A"
        details["First Word Latency"] = first_word_latency != nil ? "\(first_word_latency!) ns" : "N/A"

        return details
    }
}
