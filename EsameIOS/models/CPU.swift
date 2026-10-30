//
//  CPU.swift
//  EsameIOS
//
class CPU : Component {

    override class var categoria: TipoComponente { .cpu }

    let core_count: Int?
    let boost_clock: Double?
    let core_clock: Double?
    let microarchitecture: String?
    let tdp: Int?
    let graphics: String?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Chiave.self)
        self.core_count = try container.decodeIfPresent(Int.self, forKey: "core_count")
        self.boost_clock = try container.decodeIfPresent(Double.self, forKey: "boost_clock")
        self.core_clock = try container.decodeIfPresent(Double.self, forKey: "core_clock")
        self.microarchitecture = try container.decodeIfPresent(String.self, forKey: "microarchitecture")
        self.tdp = try container.decodeIfPresent(Int.self, forKey: "tdp")
        self.graphics = try container.decodeIfPresent(String.self, forKey: "graphics")
        try super.init(from: decoder)
    }

    override func getDetails() -> [String : Any] {
        var details = [String: Any]()

        details["Numero di core"] = core_count ?? "N/D"
        details["Clock del core"] = core_clock != nil ? "\(core_clock!) GHz" : "N/D"
        details["Boost del clock"] = boost_clock != nil ? "\(boost_clock!) GHz" : "N/D"
        details["Microarchitettura"] = microarchitecture ?? "N/D"
        details["TDP"] = tdp != nil ? "\(tdp!) W" : "N/D"
        details["Grafiche Integrate"] = graphics ?? "N/D"

        return details
    }
}
