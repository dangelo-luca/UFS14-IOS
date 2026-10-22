import SwiftUI


enum ComponentType: String, CaseIterable, Identifiable {
    case cpu = "CPU"
    case motherboard = "Motherboard"
    case gpu = "GPU"
    case ram = "RAM"
    case psu = "Power Supply"
    case storage = "Storage"
    case case_ = "Case"
    case cooler = "Cooler"

    var id: String { rawValue }

}
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
    @State private var apriDettaglio = false
    @State private var componenteSelezionato: ComponentePC?
    @State var testo: String = ""
    @State var risultati: [Risultato] = []
    @State private var scelti: [String: Risultato] = [:]
    @Environment(\.dismiss) private var dismiss
    @State private var selection: [ComponentType: SelectedPart] = [:]
    
    private var total: Double { selection.values.reduce(0) { $0 + $1.price } }
        private var progress: Double {
            Double(selection.count) / Double(ComponentType.allCases.count)
        }
    
    let componenti: [ComponentePC] = [
        ComponentePC(nome: "CPU", immagine: "cpu", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("cpu.json")),
        ComponentePC(nome: "Motherboard", immagine: "rectangle.3.group", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("motherboard.json")),
        ComponentePC(nome: "GPU", immagine: "display", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("video-card.json")),
        ComponentePC(nome: "RAM", immagine: "memorychip", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("memory.json")),
        ComponentePC(nome: "Power Supply", immagine: "powerplug", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("power-supply.json")),
        ComponentePC(nome: "Storage", immagine: "internaldrive", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("internal-hard-drive.json")),
        ComponentePC(nome: "Case", immagine: "pc", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("case.json")),
        ComponentePC(nome: "OS", immagine: "desktopcomputer", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("os.json"))
    ]
    
    var body: some View {
        NavigationStack {
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
                PriceHeader(count: selection.count,
                              total: ComponentType.allCases.count,
                              price: total,
                              progress: progress)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .background(.bar)
            }
            .navigationTitle("Crea la tua build")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Label("Indietro", systemImage: "chevron.left")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salva") { /* salva */ }
                        .fontWeight(.semibold)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .tint(.pink)
                        .controlSize(.small)
                        .disabled(selection.isEmpty)
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
}

struct ComponentCardView: View {
    let componente: ComponentePC
    var scelto: Risultato? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    Image(systemName: componente.immagine)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .frame(width: 70, height: 70)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    
                    Text(componente.nome)
                        .font(.title)
                        .bold()
                }
                
                HStack(spacing: 6) {
                    Image(systemName: scelto == nil ? "plus" : "checkmark.circle.fill")
                    Text(scelto?.nome ?? "Seleziona il componente")
                        .multilineTextAlignment(.leading)
                }
                .font(.subheadline)
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
}
