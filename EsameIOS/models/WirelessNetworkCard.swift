//
//  WirelessNetworkCard.swift
//  EsameIOS
//
class WirelessNetworkCard: Component {

    override class var categoria: TipoComponente { .networkCard }

    let interface: String?
    let `protocol`: String?
    let color: String?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Chiave.self)
        self.interface = try container.decodeIfPresent(String.self, forKey: "interface")
        self.`protocol` = try container.decodeIfPresent(String.self, forKey: "protocol")
        self.color = try container.decodeIfPresent(String.self, forKey: "color")
        try super.init(from: decoder)
    }

    override func getDetails() -> [String: Any] {
        var details = [String: Any]()

        details["Interfaccia"] = interface ?? "N/D"
        details["Protocollo"] = `protocol` ?? "N/D"
        details["Colore"] = color ?? "N/D"

        return details
    }
}
