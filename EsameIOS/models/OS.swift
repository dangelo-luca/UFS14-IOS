
//
//  OS.swift
//  EsameIOS
//
//  Created by s6 on 13/10/26.
//
import Foundation

class Os: Model, Codable, Identifiable {
    var id: String {self.name}
    let name: String
    let price: Double?
    let mode: OsMode
    let max_memory: Int
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        self.mode = try container.decode(OsMode.self, forKey: .mode)
        self.max_memory = try container.decode(Int.self, forKey: .max_memory)
    }
    
    func getDetails() -> [String: Any]{
        var details = [String: Any]()
        
        details["Memoria Massima"] = max_memory
        
        return details;
    }
}

enum OsMode: Codable {
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
            throw DecodingError.typeMismatch(OsMode.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Atteso Int o [Int]"))
        }
    }
}
