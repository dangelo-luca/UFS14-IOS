import SwiftUI

class Component: Codable, Identifiable {
    let name: String
    let price: Double?
    var id: String { name }

    class var categoria: TipoComponente { .generico }

    class var colore: Color { categoria.colore }

    var colore: Color { Self.colore }

    class var accento: Color { categoria.accento }
    var accento: Color { Self.accento }

    struct Chiave: CodingKey, ExpressibleByStringLiteral {
        let stringValue: String
        var intValue: Int? { nil }

        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
        init(stringLiteral value: String) { self.stringValue = value }
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Chiave.self)
        self.name = try container.decode(String.self, forKey: "name")
        self.price = try container.decodeIfPresent(Double.self, forKey: "price")
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Chiave.self)
        try container.encode(name, forKey: "name")
        try container.encodeIfPresent(price, forKey: "price")
    }

    func getDetails() -> [String: Any] {
        [:]
    }
}
