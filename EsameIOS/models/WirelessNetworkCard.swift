//
//  WirelessNetworkCard.swift
//  EsameIOS
//

class WirelessNetworkCard: Model, Codable, Identifiable {
    var id: String { self.name }
    let name: String
    let price: Double?
    let interface: String?
    let `protocol`: String?
    let color: String?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        self.interface = try container.decodeIfPresent(String.self, forKey: .interface)
        self.`protocol` = try container.decodeIfPresent(String.self, forKey: .protocol)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
    }

    func getDetails() -> [String: Any] {
        var details = [String: Any]()

        details["Interfaccia"] = interface ?? "N/D"
        details["Protocollo"] = `protocol` ?? "N/D"
        details["Colore"] = color ?? "N/D"

        return details
    }
}
