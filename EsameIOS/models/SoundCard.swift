class SoundCard: Component {

    override class var categoria: TipoComponente { .soundCard }

    let channels: Double?
    let digital_audio: Int?
    let snr: Int?
    let sample_rate: Double?
    let chipset: String?
    let interface: String?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Chiave.self)

        self.channels = try container.decodeIfPresent(Double.self, forKey: "channels")
        self.digital_audio = try container.decodeIfPresent(Int.self, forKey: "digital_audio")
        self.snr = try container.decodeIfPresent(Int.self, forKey: "snr")
        self.sample_rate = try container.decodeIfPresent(Double.self, forKey: "sample_rate")
        self.chipset = try container.decodeIfPresent(String.self, forKey: "chipset")
        self.interface = try container.decodeIfPresent(String.self, forKey: "interface")
        try super.init(from: decoder)
    }

    override func getDetails() -> [String: Any] {
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
