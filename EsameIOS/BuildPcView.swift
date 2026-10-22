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
    
    let componenti: [ComponentePC] = [
        ComponentePC(nome: "CPU", immagine: "cpu", fonti: RicercaView.fonti("cpu.json")),
        ComponentePC(nome: "Motherboard", immagine: "rectangle.3.group", fonti: RicercaView.fonti("motherboard.json")),
        ComponentePC(nome: "GPU", immagine: "display", fonti: RicercaView.fonti("video-card.json")),
        ComponentePC(nome: "RAM", immagine: "memorychip", fonti: RicercaView.fonti("memory.json")),
        ComponentePC(nome: "Power Supply", immagine: "powerplug", fonti: RicercaView.fonti("power-supply.json")),
        ComponentePC(nome: "Storage", immagine: "internaldrive", fonti: RicercaView.fonti("internal-hard-drive.json")),
        ComponentePC(nome: "Case", immagine: "pc", colore: .blue, fonti: RicercaView.fonti("case.json")),
        ComponentePC(nome: "OS", immagine: "desktopcomputer", fonti: RicercaView.fonti("os.json"))
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
                Spacer()
                Text("\(count)/\(total)")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.pink.opacity(0.12), in: Capsule())
                    .foregroundStyle(.pink)
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

#Preview {
    BuildPcView()
}
