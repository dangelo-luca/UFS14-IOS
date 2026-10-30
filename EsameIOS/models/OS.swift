//
//  OS.swift
//  EsameIOS
//
import Foundation

class Os: Component {

    override class var categoria: TipoComponente { .os }

    let mode: OsMode
    let max_memory: Int

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Chiave.self)
        self.mode = try container.decode(OsMode.self, forKey: "mode")
        self.max_memory = try container.decode(Int.self, forKey: "max_memory")
        try super.init(from: decoder)
    }

    override func getDetails() -> [String: Any] {
        var details = [String: Any]()

        details["Memoria Massima"] = max_memory

        return details
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
