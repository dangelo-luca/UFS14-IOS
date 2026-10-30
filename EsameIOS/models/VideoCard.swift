//
//  VideoCard.swift
//  EsameIOS
//
class VideoCard: Component {

    override class var categoria: TipoComponente { .gpu }

    let chipset: String?
    let memory: Double?
    let core_clock: Int?
    let boost_clock: Int?
    let length: Int?
    let color: String?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Chiave.self)
        self.chipset = try container.decodeIfPresent(String.self, forKey: "chipset")
        self.memory = try container.decodeIfPresent(Double.self, forKey: "memory")
        self.core_clock = try container.decodeIfPresent(Int.self, forKey: "core_clock")
        self.boost_clock = try container.decodeIfPresent(Int.self, forKey: "boost_clock")
        self.length = try container.decodeIfPresent(Int.self, forKey: "length")
        self.color = try container.decodeIfPresent(String.self, forKey: "color")
        try super.init(from: decoder)
    }

    override func getDetails() -> [String: Any] {
        var details = [String: Any]()

        details["Chipset"] = chipset ?? "N/D"
        details["Memoria"] = memory != nil ? "\(memory!) GB" : "N/D"
        details["Clock del core"] = core_clock != nil ? "\(core_clock!) MHz" : "N/D"
        details["Boost del clock"] = boost_clock != nil ? "\(boost_clock!) MHz" : "N/D"
        details["Lunghezza"] = length != nil ? "\(length!) mm" : "N/D"
        details["Colore"] = color ?? "N/D"

        return details
    }
}
