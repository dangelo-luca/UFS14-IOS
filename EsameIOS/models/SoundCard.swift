//
//  SoundCard.swift
//  EsameIOS
//

class SoundCard: Model, Codable, Identifiable {
    var id: String { self.name }
    let name: String
    let price: Double?
    let channels: Double?
    let digital_audio: Int?
    let snr: Int?
    let sample_rate: Double?
    let chipset: String?
    let interface: String?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        self.channels = try container.decodeIfPresent(Double.self, forKey: .channels)
        self.digital_audio = try container.decodeIfPresent(Int.self, forKey: .digital_audio)
        self.snr = try container.decodeIfPresent(Int.self, forKey: .snr)
        self.sample_rate = try container.decodeIfPresent(Double.self, forKey: .sample_rate)
        self.chipset = try container.decodeIfPresent(String.self, forKey: .chipset)
        self.interface = try container.decodeIfPresent(String.self, forKey: .interface)
    }

    func getDetails() -> [String: Any] {
        var details = [String: Any]()

        details["Canali"] = channels ?? "N/D"
        details["Audio digitale"] = digital_audio != nil ? "\(digital_audio!) bit" : "N/D"
        details["Rapporto segnale/rumore"] = snr != nil ? "\(snr!) dB" : "N/D"
        details["Frequenza di campionamento"] = sample_rate != nil ? "\(sample_rate!) kHz" : "N/D"
        details["Chipset"] = chipset ?? "N/D"
        details["Interfaccia"] = interface ?? "N/D"

        return details
    }
}
