//
//  CPU.swift
//  EsameIOS
//
//  Created by s6 on 13/10/26.
//
class CPU : Model, Codable, Identifiable {
    var id: String
    let name: String
    let price: Double?
    let core_count: Int?
    let boost_clock: Double?
    let core_clock: Double?
    let microarchitecture: String?
    let graphics: String?
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        self.core_count = try container.decodeIfPresent(Int.self, forKey: .core_count)
        self.boost_clock = try container.decodeIfPresent(Double.self, forKey: .boost_clock)
        self.core_clock = try container.decodeIfPresent(Double.self, forKey: .core_clock)
        self.microarchitecture = try container.decode(String.self, forKey: .microarchitecture)
        self.graphics = try container.decodeIfPresent(String.self, forKey: .graphics)
    }
    
    func getDetails() -> [String : Any] {
        var details = [String: Any]()
        
        details["Numero di core"] = core_count ?? "N/D"
        details["Clock del core"] = core_clock ?? "N/D"
        details["Boost del clock"] = boost_clock ?? "N/D"
        details["Microarchitettura"] = microarchitecture ?? "N/D"
        details["Grafiche Integrate"] = graphics ?? "N/D"
        
        return details;
    }
    
}
