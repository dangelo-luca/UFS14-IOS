//
//  PSU.swift
//  EsameIOS
//
//  Created by s6 on 13/10/26.
//
class PSU : Model, Codable, Identifiable {
    var id: String { self.name }
    let name: String
    let price: Double?
    let type: String?
    let efficiency: String?
    let wattage: Double?
    let modular: String?     // nel JSON è "Full", "Semi", "Full / Side" oppure false
    let color: String?
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.efficiency = try container.decodeIfPresent(String.self, forKey: .efficiency)
        self.wattage = try container.decodeIfPresent(Double.self, forKey: .wattage)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
        
        if let testo = try? container.decodeIfPresent(String.self, forKey: .modular) {
            self.modular = testo
        } else if let booleano = try? container.decodeIfPresent(Bool.self, forKey: .modular) {
            self.modular = booleano ? "Sì" : "No"
        } else {
            self.modular = nil
        }
    }

    func getDetails() -> [String: Any] {
        var details = [String: Any]()
        
        details["Tipo"] = type ?? "N/A"
        details["Efficienza"] = efficiency ?? "N/A"
        details["Wattaggio"] = wattage != nil ? "\(Int(wattage!)) W" : "N/A"
        details["Modularità"] = modular ?? "N/A"
        details["Colore"] = color ?? "N/A"
        
        return details
    }
}
