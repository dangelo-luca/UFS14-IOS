import SwiftUI
import SwiftData

// MARK: - Slide del carosello

enum TipoSlide {
    case build(SavedBuild)   // una build salvata
    case tutte(Int)          // "Vedi tutte le build"
    case nuova               // nessuna build: invito a crearne una
}

struct SlideCarosello {
    let tipo: TipoSlide
    let titolo: String
    let sottotitolo: String
    let icona: String
    let colore: Color
}

// Posizione orizzontale di ogni card, per capire quale è quella corrente
private struct PosizioneCard: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - Home

struct HomeView: View {
    // Azioni fornite da MainTabView (cambio scheda)
    var vaiASalvati: () -> Void = {}
    var nuovaBuild: () -> Void = {}

    // Quante build mostra il carosello
    private let maxSlideBuild = 5

    // Misure del carosello
    private let margineCarosello: CGFloat = 16
    private let altezzaCard: CGFloat = 300

    // Stesso ordine usato in BuildDetailView
    private static let ordineComponenti = [
        "CPU", "CPU Cooler", "Motherboard", "GPU", "RAM", "Power Supply",
        "Storage", "Case", "OS", "Sound Card", "Network Card"
    ]

    @State private var pagina: Int = 0
    @State private var testoRicerca: String = ""
    @Environment(BuildManager.self) private var buildStore
    @ObservedObject private var impostazioni = UserSettings.shared

    @Environment(\.modelContext) private var modelContext
    @Query var utenti: [User]

    private func firstCheck() {
        if impostazioni.user_id != "" && impostazioni.psw_hash != "" {
            if !utenti.contains(where: { $0.id == impostazioni.user_id && $0.passwordHash == impostazioni.psw_hash }) {
                impostazioni.user_id = ""
                impostazioni.psw_hash = ""
            }
        }
    }

    private var inRicerca: Bool {
        !testoRicerca.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func colore(perIndice i: Int) -> Color {
        ColoreBuild.allCases[i % ColoreBuild.allCases.count].swiftUI
    }

    // Le ultime 5 build, dalla più recente (a sinistra) alla più vecchia.
    private var slide: [SlideCarosello] {
        let build = buildStore.savedBuilds
        var risultato: [SlideCarosello] = []

        for (i, b) in Array(build.enumerated()).suffix(maxSlideBuild).reversed() {
            risultato.append(
                SlideCarosello(tipo: .build(b),
                               titolo: b.nome,
                               sottotitolo: "Tocca per vedere i dettagli",
                               icona: "desktopcomputer",
                               colore: colore(perIndice: i))
            )
        }

        if build.isEmpty {
            risultato.append(
                SlideCarosello(tipo: .nuova,
                               titolo: "Crea la tua prima build",
                               sottotitolo: "Scegli i componenti e salvala qui",
                               icona: "plus.circle.fill",
                               colore: .blue)
            )
        } else if build.count > maxSlideBuild {
            risultato.append(
                SlideCarosello(tipo: .tutte(build.count),
                               titolo: "Tutte le build",
                               sottotitolo: "\(build.count) salvate",
                               icona: "square.grid.2x2.fill",
                               colore: .gray)
            )
        }
        return risultato
    }

    // Slide attualmente visibile
    private var slideCorrente: SlideCarosello? {
        let lista = slide
        guard !lista.isEmpty else { return nil }
        return lista[min(pagina, lista.count - 1)]
    }

    var body: some View {
        ZStack(alignment: .top) {
            sfondo

            VStack(spacing: 12) {
                BarraRicerca(testo: $testoRicerca, placeholder: "Cerca componenti")
                    .padding(.horizontal)
                    .padding(.top, 8)

                if inRicerca {
                    risultatiRicerca
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            sezioneCarosello
                            sezioneRiepilogo
                            sezioneEsporta
                        }
                        .padding(.bottom, 100) // spazio per la navbar custom
                    }
                }
            }
        }
        .preferredColorScheme(impostazioni.opzioni.getTheme())
        .task {
            firstCheck()
        }
    }

    // MARK: - Sfondo tinto dal colore della slide corrente

    var sfondo: some View {
        let c = slideCorrente?.colore ?? .blue
        return ZStack(alignment: .top) {
            LinearGradient(colors: [c.opacity(0.5), c.opacity(0.0)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 440)

            Circle()
                .fill(c.opacity(0.45))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: -90, y: -70)

            Circle()
                .fill(c.opacity(0.35))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: 120, y: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.6), value: pagina)
    }

    // MARK: - Risultati della ricerca

    private var risultatiRicerca: some View {
        let trovati = cercaNeiFile(testoRicerca, in: RicercaView.tutte)
        let lista = Array(
            trovati
                .sorted { $0.nome.localizedCaseInsensitiveCompare($1.nome) == .orderedAscending }
                .prefix(30)
        )

        return ScrollView {
            if lista.isEmpty {
                Text("Nessun risultato")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(lista) { r in
                        rigaRisultato(r)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func rigaRisultato(_ r: Risultato) -> some View {
        DisclosureGroup {
            dettagliRisultato(r)
                .padding(.top, 6)
        } label: {
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
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func dettagliRisultato(_ r: Risultato) -> some View {
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

    // MARK: - Carosello
    // - 1 sola card: occupa tutta la larghezza (da margine a margine)
    // - 2 o più card: la card è un po' più stretta, così spunta il bordo della successiva

    var sezioneCarosello: some View {
        let lista = slide
        let frazione: CGFloat = lista.count > 1 ? 0.9 : 1.0

        return VStack(spacing: 12) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(lista.enumerated()), id: \.offset) { indice, s in
                        cardSlide(s)
                            .containerRelativeFrame(.horizontal) { larghezza, _ in
                                larghezza * frazione
                            }
                            .frame(height: altezzaCard)
                            // la card centrale è a grandezza piena, quella che spunta è un filo più piccola
                            .scrollTransition(axis: .horizontal) { content, phase in
                                content.scaleEffect(phase.isIdentity ? 1 : 0.95)
                            }
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: PosizioneCard.self,
                                        value: [indice: geo.frame(in: .named("carosello")).minX]
                                    )
                                }
                            )
                    }
                }
                .scrollTargetLayout()
            }
            .coordinateSpace(name: "carosello")
            .contentMargins(.horizontal, margineCarosello, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .scrollDisabled(lista.count <= 1)
            .frame(height: altezzaCard)
            .onPreferenceChange(PosizioneCard.self) { posizioni in
                // La card corrente è quella più vicina al margine sinistro
                guard let vicina = posizioni.min(by: {
                    abs($0.value - margineCarosello) < abs($1.value - margineCarosello)
                })?.key else { return }
                if vicina != pagina { pagina = vicina }
            }

            // Indicatori di pagina
            if lista.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<lista.count, id: \.self) { i in
                        Capsule()
                            .fill(i == pagina ? Color.primary : Color.primary.opacity(0.2))
                            .frame(width: i == pagina ? 22 : 7, height: 7)
                    }
                }
                .animation(.spring(duration: 0.3), value: pagina)
            }
        }
    }

    @ViewBuilder
    private func cardSlide(_ s: SlideCarosello) -> some View {
        switch s.tipo {
        case .build(let b):
            NavigationLink {
                BuildDetailView(build: b)
            } label: {
                contenutoSlide(s)
            }
            .buttonStyle(.plain)

        case .tutte:
            Button(action: vaiASalvati) {
                contenutoSlide(s)
            }
            .buttonStyle(.plain)

        case .nuova:
            Button(action: nuovaBuild) {
                contenutoSlide(s)
            }
            .buttonStyle(.plain)
        }
    }

    private func contenutoSlide(_ s: SlideCarosello) -> some View {
        ZStack(alignment: .bottomTrailing) {
            // Cerchi decorativi
            Circle()
                .fill(.white.opacity(0.12))
                .frame(width: 240, height: 240)
                .offset(x: 80, y: 90)
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 140, height: 140)
                .offset(x: -170, y: -90)

            Image(systemName: s.icona)
                .font(.system(size: 84, weight: .semibold))
                .foregroundStyle(.white.opacity(0.35))

            VStack(alignment: .leading, spacing: 14) {
                Text(s.titolo)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Text(s.sottotitolo)
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.22), in: Capsule())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(colors: [s.colore, s.colore.opacity(0.65)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .shadow(color: s.colore.opacity(0.35), radius: 16, y: 8)
    }

    // MARK: - Riepilogo della build selezionata nel carosello

    private func righeRiepilogo(_ b: SavedBuild)
        -> [(categoria: String, selezione: Selezione)] {
        b.componenti
            .sorted { a, c in
                let ia = Self.ordineComponenti.firstIndex(of: a.key) ?? Int.max
                let ic = Self.ordineComponenti.firstIndex(of: c.key) ?? Int.max
                return ia < ic
            }
            .map { (categoria: $0.key, selezione: $0.value) }
    }

    @ViewBuilder
    var sezioneRiepilogo: some View {
        if let s = slideCorrente, case .build(let b) = s.tipo {
            let righe = righeRiepilogo(b)

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Text("Riepilogo")
                        .font(.title3.bold())
                    Spacer()
                    Text("\(righe.count) componenti")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    // Apre BuildPcView con la build selezionata già caricata
                    NavigationLink {
                        BuildPcView(buildDaModificare: b)
                    } label: {
                        Text("Modifica")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(s.colore, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }

                VStack(spacing: 0) {
                    ForEach(Array(righe.enumerated()), id: \.offset) { i, r in
                        let accento = r.selezione.risultato.modello.accento
                        let nome = r.selezione.quantita > 1
                            ? "\(r.selezione.quantita) × \(r.selezione.risultato.nome)"
                            : r.selezione.risultato.nome

                        HStack(spacing: 10) {
                            // Badge colorato con il nome del componente
                            Text(nome)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(accento)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(accento.opacity(0.14), in: Capsule())

                            Spacer(minLength: 8)

                            
                        }
                        .padding(.vertical, 10)

                        if i < righe.count - 1 {
                            Divider()
                        }
                    }
                }

                Divider()

                HStack {
                    Text("Totale")
                        .font(.title3.bold())
                    Spacer()
                    Text(b.totale, format: .currency(code: "EUR"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(s.colore)
                        .contentTransition(.numericText())
                }
            }
            .padding(20)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
            .padding(.horizontal)
            .animation(.easeInOut(duration: 0.3), value: pagina)
        } else if let s = slideCorrente, case .tutte(let n) = s.tipo {
            Text("Hai \(n) build salvate: aprile tutte dalla scheda Salvati.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }

    // MARK: - Esporta (lista neutra)

    var sezioneEsporta: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Esporta")
                .font(.title3.bold())
                .padding(.horizontal)

            if buildStore.savedBuilds.isEmpty {
                Text("Quando salverai una build potrai esportarla da qui.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(buildStore.savedBuilds.enumerated()), id: \.offset) { _, build in
                        Button {
                            // Azione esporta
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "arrow.up.forward.app.fill")
                                    .font(.title3)
                                    .foregroundStyle(.orange)
                                    .frame(width: 42, height: 42)
                                    .background(.orange.opacity(0.15), in: Circle())

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(build.nome)
                                        .font(.subheadline.bold())
                                    Text("Tocca per esportare")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(14)
                            .background(.regularMaterial,
                                        in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(BuildManager())
}
