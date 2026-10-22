//
//  HardDrive.swift
//  EsameIOS
//
//  Created by s6 on 13/10/26.
//
class HardDrive : Model, Codable, Identifiable {
    var id: String {self.name}
    let name: String
    let price: Double?
    let capacity: Double
    let price_per_gb: Double?
    let type: Type
    let cache: Double?
    let form_factor: Double?
    let interface: String?
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        self.capacity = try container.decode(Double.self, forKey: .capacity)
        self.price_per_gb = try container.decodeIfPresent(Double.self, forKey: .price_per_gb)
        self.type = try container.decode(Type.self, forKey: .type)
        self.cache = try container.decodeIfPresent(Double.self, forKey: .cache)
        self.form_factor = try container.decodeIfPresent(Double.self, forKey: .form_factor)
        self.interface = try container.decodeIfPresent(String.self, forKey: .interface)
    }

    func getDetails() -> [String: Any]{
        var details = [String: Any]()
        
        details["Capacità"] = capacity
        details["Cache"] = cache ?? "N/A"

        switch(type){
        case .intero(let rpm):
            details["Tipo"] = "HDD" 
            details["RPM"] = "\(rpm) RPM"
        case .stringa(let tipo):
            details["Tipo"] = tipo 
        }
        
        details["Fattore di forma"] = form_factor ?? "N/A"
        details["Interfaccia"] = interface ?? "N/A"
        
        return details;
    }
}

enum Type: Codable {
    case intero(Int)
    case stringa(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let valore = try? container.decode(Int.self) {
            self = .intero(valore)
        }
        else if let stringa = try? container.decode(String.self) {
            self = .stringa(stringa)
        }
        else {
            throw DecodingError.typeMismatch(OsMode.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Atteso Int o String"))
        }
    }
}
