//
//  RAM.swift
//  EsameIOS
//
//  Created by s6 on 13/10/26.
//
class RAM : Model, Codable, Identifiable {
    var id: String { self.name }
    let name: String
    let price: Double?
    let speed: [Double]       // [generazione DDR, MHz]; in rari casi è un solo numero
    let module: [Double]      // [numero moduli, GB per modulo]
    let color: String?
    let first_word_latency: Double?
    
    // nel JSON la chiave si chiama "modules", non "module"
    enum CodingKeys: String, CodingKey {
        case name, price, speed, color, first_word_latency
        case module = "modules"
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        
        if let lista = try? container.decode([Double].self, forKey: .speed) {
            self.speed = lista
        } else {
            self.speed = [try container.decode(Double.self, forKey: .speed)]
        }
        
        self.module = try container.decode([Double].self, forKey: .module)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
        self.first_word_latency = try container.decodeIfPresent(Double.self, forKey: .first_word_latency)
    }

    func getDetails() -> [String: Any] {
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
