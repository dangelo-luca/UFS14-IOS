class Case : Component {

    override class var categoria: TipoComponente { .pcCase }

    let type: String?
    let color: String?
    let side_panel: String?
    let external_volume: Double?
    let internal_35_bays: Int?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Chiave.self)
        self.type = try container.decodeIfPresent(String.self, forKey: "type")
        self.color = try container.decodeIfPresent(String.self, forKey: "color")
        self.side_panel = try container.decodeIfPresent(String.self, forKey: "side_panel")
        self.external_volume = try container.decodeIfPresent(Double.self, forKey: "external_volume")
        self.internal_35_bays = try container.decodeIfPresent(Int.self, forKey: "internal_35_bays")
        try super.init(from: decoder)
    }

    override func getDetails() -> [String : Any] {
        var details = [String: Any]()

        details["Tipo"] = type ?? "N/D"
        details["Colore"] = color ?? "N/D"
        details["Pannello laterale"] = side_panel ?? "N/D"
        details["Volume esterno"] = external_volume ?? "N/D"
        details["Slot per HDD"] = internal_35_bays ?? "N/D"

        return details
    }
}
