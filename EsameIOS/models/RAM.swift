//
//  HardDrive.swift
//  EsameIOS
//
//  Created by s6 on 13/10/26.
//
class RAM : Model, Codable, Identifiable {
    var id: String {self.name}
    let name: String
    let price: Double?
    let speed: [Double]
    let module: [Double]
    let color: String?
    let first_word_latency: Double?
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        self.speed = try container.decode([Double].self, forKey: .speed)
        self.module = try container.decode([Double].self, forKey: .module)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
        self.first_word_latency = try container.decodeIfPresent(Double.self, forKey: .first_word_latency)
    }

    func getDetails() -> [String: Any]{
        var details = [String: Any]()
        
        details["Tipo"] = "DDR\(speed[0])"
        details["Velocità"] = "\(speed[1]) MHz"
        details["Capacità"] = "\(Int(module[0])) x \(Int(module[1])) GB"
        details["Colore"] = color ?? "N/A"
        details["First Word Latency"] = first_word_latency != nil ? "\(first_word_latency!) ns" : "N/A"
        
        return details;
    }
}
