import SwiftUI

// MARK: - Opzioni di ordinamento
enum OrdineRicerca: String, CaseIterable {
    case nomeAZ = "Nome (A-Z)"
    case nomeZA = "Nome (Z-A)"
    case prezzoCrescente = "Prezzo crescente"
    case prezzoDecrescente = "Prezzo decrescente"

    var titoloLocalizzato: LocalizedStringKey {
        switch self {
        case .nomeAZ: return "Nome (A-Z)"
        case .nomeZA: return "Nome (Z-A)"
        case .prezzoCrescente: return "Prezzo crescente"
        case .prezzoDecrescente: return "Prezzo decrescente"
        }
    }
}

// MARK: - Risultato di ricerca
struct Risultato: Identifiable, Codable {
    var id = UUID()
    let categoria: String
    let nome: String
    let prezzo: Double?
    let modello: Component

    var dettagli: [String: Any] { modello.getDetails() }
}

func formattaValore(_ valore: Any) -> String {
    let specchio = Mirror(reflecting: valore)
    if specchio.displayStyle == .optional {
        if let interno = specchio.children.first?.value { return formattaValore(interno) }
        return "N/D"
    }
    if let numero = valore as? Double, numero.isFinite, abs(numero) < 1e15, numero == numero.rounded() {
        return String(Int(numero))
    }
    return "\(valore)"
}

// MARK: - Componente Pulsante Filtro Separato
struct PulsanteFiltro: View {
    @Binding var ordine: OrdineRicerca
    
    private var haFiltroAttivo: Bool {
        ordine != .nomeAZ
    }

    var body: some View {
        Menu {
            Picker("Ordina per", selection: $ordine) {
                ForEach(OrdineRicerca.allCases, id: \.self) { opzione in
                    Text(opzione.titoloLocalizzato).tag(opzione)
                }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(haFiltroAttivo ? Color.blue : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(haFiltroAttivo ? .white : .primary)
            }
        }
    }
}

// MARK: - Barra di Ricerca Separata
struct BarraRicerca: View {
    @Binding var testo: String
    var placeholder: LocalizedStringKey = "Cerca componenti"

    var body: some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: $testo)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !testo.isEmpty {
                Button {
                    testo = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }

            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(Color.gray.opacity(0.2))
        .clipShape(Capsule())
    }
}

// MARK: - RicercaView
struct RicercaView: View {
    static let tutte: [Fonte] = [
        Fonte("case.json", Case.self),
        Fonte("cpu.json", CPU.self),
        Fonte("cpu-cooler.json", CPU_Fan.self),
        Fonte("internal-hard-drive.json", HardDrive.self),
        Fonte("motherboard.json", Motherboard.self),
        Fonte("os.json", Os.self),
        Fonte("power-supply.json", PSU.self),
        Fonte("memory.json", RAM.self),
        Fonte("sound-card.json", SoundCard.self),
        Fonte("video-card.json", VideoCard.self),
        Fonte("wireless-network-card.json", WirelessNetworkCard.self)
    ]

    static func fonti(_ files: String...) -> [Fonte] {
        tutte.filter { files.contains($0.file) }
    }

    var cerca: [Fonte] = RicercaView.tutte
    var placeholder: LocalizedStringKey = "Cerca componenti"
    var alSelezionare: ((Risultato) -> Void)? = nil

    @State private var testo: String = ""
    @State private var ordine: OrdineRicerca = .nomeAZ

    func ordinaRisultati(_ dati: [Risultato]) -> [Risultato] {
        dati.sorted { r1, r2 in
            switch ordine {
            case .nomeAZ:
                return r1.nome.localizedCaseInsensitiveCompare(r2.nome) == .orderedAscending
            case .nomeZA:
                return r1.nome.localizedCaseInsensitiveCompare(r2.nome) == .orderedDescending
            case .prezzoCrescente:
                return (r1.prezzo ?? 0) < (r2.prezzo ?? 0)
            case .prezzoDecrescente:
                return (r1.prezzo ?? 0) > (r2.prezzo ?? 0)
            }
        }
    }

    var body: some View {
        let trovati = cercaNeiFile(testo, in: cerca)
        let ordinati = ordinaRisultati(trovati)
        let risultati = Array(ordinati.prefix(50))

        return VStack(spacing: 12) {
            // Barra di ricerca e Filtro separati e affiancati
            HStack(spacing: 12) {
                BarraRicerca(testo: $testo, placeholder: placeholder)
                PulsanteFiltro(ordine: $ordine)
            }
            .padding(.horizontal)

            if testo.isEmpty {
                messaggio("Scrivi il nome di un componente")
            } else if risultati.isEmpty {
                messaggio("Nessun risultato")
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(risultati) { r in
                            riga(r)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    func messaggio(_ testo: LocalizedStringKey) -> some View {
        VStack {
            Spacer().frame(height: 40)
            Text(testo)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    @ViewBuilder
    func riga(_ r: Risultato) -> some View {
        if let azione = alSelezionare {
            Button {
                azione(r)
            } label: {
                intestazioneRiga(r)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)
        } else {
            DisclosureGroup {
                dettagliRiga(r)
                    .padding(.top, 6)
            } label: {
                intestazioneRiga(r)
            }
            .padding()
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    func intestazioneRiga(_ r: Risultato) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(r.nome)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text(LocalizedStringKey(r.categoria))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let p = r.prezzo {
                Text(String(format: "%.2f €", p))
                    .font(.subheadline)
            }
        }
    }

    func dettagliRiga(_ r: Risultato) -> some View {
        let d = r.dettagli
        return VStack(alignment: .leading, spacing: 4) {
            ForEach(d.keys.sorted(), id: \.self) { chiave in
                HStack {
                    Text(LocalizedStringKey(chiave))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(LocalizedStringKey(formattaValore(d[chiave] ?? "N/D")))
                }
                .font(.caption)
            }
        }
    }
}

#Preview {
    RicercaView(cerca: [Fonte("cpu.json", CPU.self)])
}
