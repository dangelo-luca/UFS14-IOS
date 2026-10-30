//
//  Motherboard.swift
//  EsameIOS
//
class Motherboard : Component {

    override class var categoria: TipoComponente { .motherboard }

    let socket: String?
    let form_factor: String?
    let max_memory: Double?
    let memory_slots: Double?
    let color: String?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Chiave.self)
        self.socket = try container.decodeIfPresent(String.self, forKey: "socket")
        self.form_factor = try container.decodeIfPresent(String.self, forKey: "form_factor")
        self.max_memory = try container.decodeIfPresent(Double.self, forKey: "max_memory")
        self.memory_slots = try container.decodeIfPresent(Double.self, forKey: "memory_slots")
        self.color = try container.decodeIfPresent(String.self, forKey: "color")
        try super.init(from: decoder)
    }

    override func getDetails() -> [String: Any] {
        var details = [String: Any]()

        details["Socket"] = socket ?? "N/A"
        details["Form Factor"] = form_factor ?? "N/A"
        details["Memoria massima"] = max_memory != nil ? "\(Int(max_memory!)) GB" : "N/A"
        details["Slot di memoria"] = memory_slots != nil ? "\(Int(memory_slots!))" : "N/A"
        details["Colore"] = color ?? "N/A"

        return details
    }
}
