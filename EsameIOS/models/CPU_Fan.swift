//
//  CPU_Fan.swift
//  EsameIOS
//
//  Created by s6 on 13/10/26.
//
class CPU_Fan : Model, Codable, Identifiable {
    var id: String { self.name }
    let name: String
    let price: Double?
    let rpm: RPM?                    // nel JSON può essere null
    let noise_level: NoiseLevel?     // nel JSON può essere null
    let color: String?
    let size: Double?
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        self.rpm = try container.decodeIfPresent(RPM.self, forKey: .rpm)
        self.noise_level = try container.decodeIfPresent(NoiseLevel.self, forKey: .noise_level)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
        self.size = try container.decodeIfPresent(Double.self, forKey: .size)
    }
    
    func getDetails() -> [String : Any] {
        var details = [String: Any]()
        
        if let rpm = rpm {
            switch rpm {
            case .singolo(let valore):
                details["RPM"] = valore
            case .multiplo(let valori):
                details["RPM"] = valori.map { "\($0)" }.joined(separator: " - ")
            }
        } else {
            details["RPM"] = "N/D"
        }
        
        if let noise = noise_level {
            switch noise {
            case .singolo(let valore):
                details["Livello di rumore"] = valore
            case .multiplo(let valori):
                details["Livello di rumore"] = valori.map { "\($0)" }.joined(separator: " - ")
            }
        } else {
            details["Livello di rumore"] = "N/D"
        }
        
        details["Colore"] = color ?? "N/D"
        details["Grandezza"] = size ?? "N/D"
        
        return details
    }
}

enum NoiseLevel: Codable {
    case singolo(Double)
    case multiplo([Double])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let valoreSingolo = try? container.decode(Double.self) {
            self = .singolo(valoreSingolo)
        }
        else if let arrayValori = try? container.decode([Double].self) {
            self = .multiplo(arrayValori)
        }
        else {
            throw DecodingError.typeMismatch(NoiseLevel.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Atteso Double o [Double]"))
        }
    }
}

enum RPM: Codable {
    case singolo(Int)
    case multiplo([Int])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let valoreSingolo = try? container.decode(Int.self) {
            self = .singolo(valoreSingolo)
        }
        else if let arrayValori = try? container.decode([Int].self) {
            self = .multiplo(arrayValori)
        }
        else {
            throw DecodingError.typeMismatch(RPM.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Atteso Int o [Int]"))
        }
    }
}
