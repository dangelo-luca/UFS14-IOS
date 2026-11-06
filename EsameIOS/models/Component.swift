import SwiftUI

class Component: Codable, Identifiable {
    let name: String
    let price: Double?
    var id: String { name }

    /// Categoria del componente. Ogni sottoclasse la ridefinisce con `override class var categoria`.
    class var categoria: TipoComponente { .generico }

    /// Colore del TIPO di componente (si legge anche senza istanza: CPU.colore).
    class var colore: Color { categoria.colore }

    /// Colore del componente (quando hai già l'oggetto: modello.colore).
    var colore: Color { Self.colore }

    /// Colore per testi/dettagli, leggibile in modalità chiara e scura.
    class var accento: Color { categoria.accento }
    var accento: Color { Self.accento }

    /// Chiave JSON "dinamica": sostituisce gli enum CodingKeys di ogni modello.
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

    /// Le sottoclassi la ridefiniscono con `override`.
    func getDetails() -> [String: Any] {
        [:]
    }
}
