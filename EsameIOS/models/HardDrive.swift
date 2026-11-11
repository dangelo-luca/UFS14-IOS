import Foundation

class HardDrive : Component {

    override class var categoria: TipoComponente { .storage }

    let capacity: Double
    let price_per_gb: Double?
    let type: DriveType?
    let cache: Double?
    let form_factor: String?
    let interface: String?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Chiave.self)
        self.capacity = try container.decode(Double.self, forKey: "capacity")
        self.price_per_gb = try container.decodeIfPresent(Double.self, forKey: "price_per_gb")
        self.type = try container.decodeIfPresent(DriveType.self, forKey: "type")
        self.cache = try container.decodeIfPresent(Double.self, forKey: "cache")
        self.interface = try container.decodeIfPresent(String.self, forKey: "interface")

        if let testo = try? container.decodeIfPresent(String.self, forKey: "form_factor") {
            self.form_factor = testo
        } else if let numero = try? container.decodeIfPresent(Double.self, forKey: "form_factor") {
            self.form_factor = "\(numero)\""
        } else {
            self.form_factor = nil
        }
        try super.init(from: decoder)
    }

    override func getDetails() -> [String: Any] {
        var details = [String: Any]()

        details["Capacità"] = String(format: "%g GB", capacity)
        details["Cache"] = cache != nil ? "\(Int(cache!)) MB" : "N/A"

        if let type = type {
            switch type {
            case .intero(let rpm):
                details["Tipo"] = "HDD"
                details["RPM"] = "\(rpm) RPM"
            case .stringa(let tipo):
                details["Tipo"] = tipo
            }
        } else {
            details["Tipo"] = "N/A"
        }

        details["Fattore di forma"] = form_factor ?? "N/A"
        details["Interfaccia"] = interface ?? "N/A"

        return details
    }
}

enum DriveType: Codable {
    case intero(Int)
    case stringa(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let valore = try? container.decode(Int.self) {
            self = .intero(valore)
        }
        else if let stringa = try? container.decode(String.self) {
            self = .stringa(stringa)
        }
        else {
            throw DecodingError.typeMismatch(DriveType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Atteso Int o String"))
        }
    }
}
