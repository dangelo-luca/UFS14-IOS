import SwiftUI

// MARK: - Risultato di ricerca
// Contiene il modello vero (Case, CPU, RAM...) così chi usa RicercaView
// può fare ad esempio: risultato.modello as? CPU

struct Risultato: Identifiable {
    let id = UUID()
    let categoria: String
    let nome: String
    let prezzo: Double?
    let modello: any Model

    var dettagli: [String: Any] { modello.getDetails() }
}

// Trasforma un valore di getDetails() in testo (toglie "Optional(...)" e i ".0" inutili)
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

// MARK: - Barra di ricerca (usata da RicercaView e da Components)
struct BarraRicerca: View {
    @Binding var testo: String
    var placeholder: String = "Cerca componenti"

    var body: some View {
        HStack {
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
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color.gray.opacity(0.2))
        .clipShape(Capsule())
        .padding(.horizontal, 30)
       
       
    }
}

// MARK: - RicercaView
struct RicercaView: View {
    // Creata una sola volta: i json restano in memoria
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

    // Prende dalle fonti condivise solo quelle dei file indicati
    static func fonti(_ files: String...) -> [Fonte] {
        tutte.filter { files.contains($0.file) }
    }

    var cerca: [Fonte] = RicercaView.tutte
    var placeholder: String = "Cerca componenti"
    var alSelezionare: ((Risultato) -> Void)? = nil

    @State private var testo: String = ""

    var body: some View {
        // Massimo 50 risultati per tenere la lista leggera
        let risultati = Array(cercaNeiFile(testo, in: cerca).prefix(50))

        return VStack(spacing: 12) {
            // Barra di ricerca posizionata in alto
            BarraRicerca(testo: $testo, placeholder: placeholder)

            // Risultati o messaggi di stato
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
                }
            }
        }
        
    }

    func messaggio(_ testo: String) -> some View {
        Text(testo)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Riga del risultato
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
                Text(r.categoria)
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

    // Mostra i dettagli presi da getDetails() del modello
    func dettagliRiga(_ r: Risultato) -> some View {
        let d = r.dettagli
        return VStack(alignment: .leading, spacing: 4) {
            ForEach(d.keys.sorted(), id: \.self) { chiave in
                HStack {
                    Text(chiave)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(formattaValore(d[chiave] ?? "N/D"))
                }
                .font(.caption)
            }
        }
    }
}

#Preview {
    RicercaView(cerca: [Fonte("cpu.json", CPU.self)])
}
