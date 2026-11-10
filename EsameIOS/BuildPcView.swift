import SwiftUI

struct ComponentePC: Identifiable {
    let id = UUID()
    let nome: String
    let immagine: String
    let tipo: Component.Type
    var fonti: [Fonte] = []
    var maxQuantita: Int = 1

    var colore: Color { tipo.colore }
}

struct SelectedPart {
    let name: String
    let price: Double
}

struct BuildPcView: View {
    @Environment(BuildManager.self) private var buildManager
    @ObservedObject private var impostazioni = UserSettings.shared
    var onSalvato: () -> Void = {}
    @State private var mostraNomeBuild = false
    @State private var mostraLogin = false
    @State private var nomeBuild = ""
    @State private var apriDettaglio = false
    @State private var componenteSelezionato: ComponentePC?
    @State var testo: String = ""
    @State var risultati: [Risultato] = []
    @State private var scelti: [String: Selezione]

    init(buildDaModificare: SavedBuild? = nil, onSalvato: @escaping () -> Void = {}) {
        self.buildDaModificare = buildDaModificare
        self.onSalvato = onSalvato
        _scelti = State(initialValue: buildDaModificare?.componenti ?? [:])
    }

    private var isModifica: Bool { buildDaModificare != nil }

    private var total: Double {
        scelti.values.map(\.subtotale).reduce(0, +)
    }

    private var progress: Double {
        guard !componenti.isEmpty else { return 0 }
        return Double(scelti.count) / Double(componenti.count)
    }

    let componenti: [ComponentePC] = [
        ComponentePC(nome: "CPU", immagine: "cpu", tipo: CPU.self, fonti: RicercaView.fonti("cpu.json"), maxQuantita: 1),
        ComponentePC(nome: "CPU Cooler", immagine: "fan", tipo: CPU_Fan.self, fonti: RicercaView.fonti("cpu-cooler.json"), maxQuantita: 1),
        ComponentePC(nome: "Motherboard", immagine: "rectangle.3.group", tipo: Motherboard.self, fonti: RicercaView.fonti("motherboard.json"), maxQuantita: 1),
        ComponentePC(nome: "GPU", immagine: "display", tipo: VideoCard.self, fonti: RicercaView.fonti("video-card.json"), maxQuantita: 2),
        ComponentePC(nome: "RAM", immagine: "memorychip", tipo: RAM.self, fonti: RicercaView.fonti("memory.json"), maxQuantita: 1),
        ComponentePC(nome: "Power Supply", immagine: "powerplug.fill", tipo: PSU.self, fonti: RicercaView.fonti("power-supply.json"), maxQuantita: 1),
        ComponentePC(nome: "Storage", immagine: "internaldrive", tipo: HardDrive.self, fonti: RicercaView.fonti("internal-hard-drive.json"), maxQuantita: 10),
        ComponentePC(nome: "Case", immagine: "macpro.gen3", tipo: Case.self, fonti: RicercaView.fonti("case.json"), maxQuantita: 1),
        ComponentePC(nome: "OS", immagine: "gearshape.2", tipo: Os.self, fonti: RicercaView.fonti("os.json"), maxQuantita: 1),
        ComponentePC(nome: "Sound Card", immagine: "waveform", tipo: SoundCard.self, fonti: RicercaView.fonti("sound-card.json"), maxQuantita: 1),
        ComponentePC(nome: "Network Card", immagine: "wifi", tipo: WirelessNetworkCard.self, fonti: RicercaView.fonti("wireless-network-card.json"), maxQuantita: 1)
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(componenti) { comp in
                    ComponentCardView(componente: comp, scelto: scelti[comp.nome], onQuantita: { scelti[comp.nome]?.quantita = $0 }) {
                        componenteSelezionato = comp
                        apriDettaglio = true
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 80) // Altezza approssimativa della tua navbar custom
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
        .navigationTitle(isModifica ? "Modifica Build" : "Crea Build")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Salva") {
                    // In modifica il nome parte da quello attuale
                    nomeBuild = buildDaModificare?.nome ?? ""
                    mostraNomeBuild = true
                }
                .fontWeight(.semibold)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(.pink)
                .controlSize(.small)
                .disabled(scelti.isEmpty)
                .alert("Nome della build", isPresented: $mostraNomeBuild) {
                    TextField(
                        buildDaModificare?.nome ?? "Build #\(buildManager.savedBuilds.count + 1)",
                        text: $nomeBuild
                    )
                    .textInputAutocapitalization(.words)

                    Button("Annulla", role: .cancel) { }

                    Button("Salva") {
                        if impostazioni.isLogged {
                            nomeBuild = ""
                            mostraNomeBuild = true
                        } else {
                            mostraLogin = true
                        }
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(.pink)
                    .controlSize(.small)
                    .disabled(scelti.isEmpty)
                    .alert("Nome della build", isPresented: $mostraNomeBuild) {
                        TextField("Build #\(buildManager.savedBuilds.count + 1)", text: $nomeBuild)
                            .textInputAutocapitalization(.words)

                        Button("Annulla", role: .cancel) { }

                        Button("Salva") {
                            let nome = nomeBuild.trimmingCharacters(in: .whitespacesAndNewlines)
                            buildManager.aggiungiBuild(scelti: scelti, nomeCustom: nome)
                            scelti = [:]
                            onSalvato()
                        }
                    }
                } message: {
                    Text(isModifica
                         ? "Puoi cambiare il nome oppure lasciarlo uguale."
                         : "Scegli un nome per riconoscerla tra le build salvate.")
                }
            }
        }
        .navigationDestination(isPresented: $apriDettaglio) {
            if let comp = componenteSelezionato {
                Components(titolo: comp.nome, fonti: comp.fonti, colore: comp.colore) { r in
                    let quantita = scelti[comp.nome]?.quantita ?? 1
                    scelti[comp.nome] = Selezione(risultato: r, quantita: quantita)
                }
            }
        }
        .sheet(isPresented: $mostraLogin) {
            NavigationStack {
                AuthView {
                    nomeBuild = ""
                    mostraNomeBuild = true
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Annulla") {
                            mostraLogin = false
                        }
                    }
                }
            }
        }
    }
}

struct ComponentCardView: View {
    let componente: ComponentePC
    var scelto: Selezione? = nil
    var onQuantita: (Int) -> Void = { _ in }
    let action: () -> Void

    private var coloreCard: Color {
        scelto == nil ? TipoComponente.generico.colore : componente.colore
    }

    var body: some View {
        VStack(spacing: 12) {
            Button(action: action) {
                HStack(spacing: 26) {
                    Image(systemName: componente.immagine)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .frame(width: 70, height: 70)
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(100)

                    VStack(spacing: 6) {
                        Text(componente.nome)
                            .font(.title)
                            .bold()

                        Text(scelto?.risultato.nome ?? "Seleziona il componente")
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if let scelto, componente.maxQuantita > 1 {
                Stepper(
                    value: Binding(get: { scelto.quantita }, set: onQuantita),
                    in: 1...componente.maxQuantita
                ) {
                    Text("Quantità: \(scelto.quantita)")
                        .fontWeight(.semibold)
                }.colorScheme(.dark)
            }
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(coloreCard)
        )
        .animation(.easeInOut(duration: 0.3), value: scelto == nil)
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
