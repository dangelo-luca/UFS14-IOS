import SwiftUI

struct ComponentePC: Identifiable {
    let id = UUID()
    let nome: String
    let immagine: String
    var colore: Color = .gray
    var fonti: [Fonte] = []
}

struct SelectedPart {
    let name: String
    let price: Double
}

struct BuildPcView: View {
    @Environment(BuildManager.self) private var buildManager
    var onSalvato: () -> Void = {}   // <- nuova
    
    @State private var apriDettaglio = false
    @State private var componenteSelezionato: ComponentePC?
    @State var testo: String = ""
    @State var risultati: [Risultato] = []
    
    @State private var scelti: [String: Risultato] = [:]
    
    private var total: Double {
        scelti.values.compactMap { $0.prezzo }.reduce(0, +)
    }
    
    private var progress: Double {
        guard !componenti.isEmpty else { return 0 }
        return Double(scelti.count) / Double(componenti.count)
    }
    
    let componenti: [ComponentePC] = [
        ComponentePC(nome: "CPU", immagine: "cpu", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("cpu.json")),
        ComponentePC(nome: "CPU Cooler", immagine: "fan", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("cpu-cooler.json")),
        ComponentePC(nome: "Motherboard", immagine: "rectangle.3.group", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("motherboard.json")),
        ComponentePC(nome: "GPU", immagine: "display", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("video-card.json")),
        ComponentePC(nome: "RAM", immagine: "memorychip", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("memory.json")),
        ComponentePC(nome: "Power Supply", immagine: "powerplug.fill", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("power-supply.json")),
        ComponentePC(nome: "Storage", immagine: "internaldrive", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("internal-hard-drive.json")),
        ComponentePC(nome: "Case", immagine: "macpro.gen3", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("case.json")),
        ComponentePC(nome: "OS", immagine: "gearshape.2", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("os.json")),
        ComponentePC(nome: "Sound Card", immagine: "waveform", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("sound-card.json")),
        ComponentePC(nome: "Network Card", immagine: "wifi", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("wireless-network-card.json"))
    ]
    
    var body: some View {
        // Rimosso NavigationStack da qui
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(componenti) { comp in
                    ComponentCardView(componente: comp, scelto: scelti[comp.nome]) {
                        componenteSelezionato = comp
                        apriDettaglio = true
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            PriceHeader(
                count: scelti.count,
                total: componenti.count,
                price: total,
                progress: progress
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(.bar)
        }
        .navigationTitle("Crea la tua build")
        .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // ToolbarItem "Indietro" RIMOSSO: essendo la radice dello stack
                // non c'è nulla a cui tornare, la navigazione si fa con la barra in basso
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salva") {
                        buildManager.aggiungiBuild(scelti: scelti)
                        scelti = [:]      // azzera la selezione
                        onSalvato()       // vai alla Home
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(.pink)
                    .controlSize(.small)
                    .disabled(scelti.isEmpty)
                }
            }
        .navigationDestination(isPresented: $apriDettaglio) {
            if let comp = componenteSelezionato {
                Components(titolo: comp.nome, fonti: comp.fonti) { r in
                    scelti[comp.nome] = r
                }
            }
        }
    }
}

struct ComponentCardView: View {
    let componente: ComponentePC
    var scelto: Risultato? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 26) {
                    Image(systemName: componente.immagine)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .frame(width: 70, height: 70)
                        .background(Color.cyan.opacity(0.9))
                        .cornerRadius(100)
                    
                    VStack(spacing: 6) {
                        Text(componente.nome)
                            .font(.title)
                            .bold()
                       
                        Text(scelto?.nome ?? "Seleziona il componente")
                            .multilineTextAlignment(.leading)
                    }
                    
                    
                    
                }
                
                
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(componente.colore)
            )
        }
    }
}

struct PriceHeader: View {
    let count: Int
    let total: Int
    let price: Double
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Totale stimato")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(price, format: .currency(code: "EUR"))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                }
                Spacer()
                Text("\(count)/\(total)")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.pink.opacity(0.12), in: Capsule())
                    .foregroundStyle(.pink)
            }

            ProgressView(value: progress)
                .tint(.pink)
                .scaleEffect(x: 1, y: 1.6, anchor: .center)
                .animation(.spring, value: progress)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
    }
}

#Preview {
    BuildPcView()
        .environment(BuildManager())
}
