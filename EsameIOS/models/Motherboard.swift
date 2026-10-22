//
//  HardDrive.swift
//  EsameIOS
//
//  Created by s6 on 13/10/26.
//
//
class Motherboard : Model, Codable, Identifiable {
    var id: String {self.name}
    let name: String
    let price: Double?
    let socket: String?
    let form_factor: String?
    let max_memory: Double?
    let memory_slots: Double?
    let color: String?
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        self.socket = try container.decodeIfPresent(String.self, forKey: .socket)
        self.form_factor = try container.decodeIfPresent(String.self, forKey: .form_factor)       
        self.max_memory = try container.decodeIfPresent(Double.self, forKey: .max_memory)
        self.memory_slots = try container.decodeIfPresent(Double.self, forKey: .memory_slots)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
    }

    func getDetails() -> [String: Any]{
        var details = [String: Any]()
        
        details["Socket"] = socket ?? "N/A"
        details["Form Factor"] = form_factor ?? "N/A"
        details["Memoria massima"] = max_memory != nil ? "\(Int(max_memory!)) GB" : "N/A"
        details["Slot di memoria"] = memory_slots != nil ? "\(Int(memory_slots!))"
        details["Colore"] = color ?? "N/A"
        
        return details;
    }
}
