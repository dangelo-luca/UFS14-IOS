import SwiftUI

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

// MARK: - Home

struct HomeView: View {
    // Azioni fornite da MainTabView (cambio scheda)
    var vaiASalvati: () -> Void = {}
    var nuovaBuild: () -> Void = {}

    // Quante build mostra il carosello
    private let maxSlideBuild = 5

    @State private var pagina: Int = 0
    @State private var testoRicerca: String = ""
    @Environment(BuildManager.self) private var buildStore
    @ObservedObject private var impostazioni = UserSettings.shared

    private var inRicerca: Bool {
        !testoRicerca.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // Colore di una build in base alla sua posizione tra TUTTE le build salvate.
    // Provvisorio: quando SavedBuild avrà la proprietà `color`, usa quella.
    private func colore(perIndice i: Int) -> Color {
        ColoreBuild.allCases[i % ColoreBuild.allCases.count].swiftUI
    }

    // Ultime 5 build.
    // - nessuna build: slide "Crea la tua prima build"
    // - da 1 a 5 build: slide finale grigia "Tutte le build"
    // - 6 o più build: la slide grigia sparisce
    private var slide: [SlideCarosello] {
        let build = buildStore.savedBuilds
        var risultato: [SlideCarosello] = []

        for (i, b) in Array(build.enumerated()).suffix(maxSlideBuild) {
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
        } else if build.count <= maxSlideBuild {
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

    var body: some View {
        // Niente NavigationStack qui: c'è già quello in MainTabView
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
                            sezioneAzioniBuild
                            sezioneEsporta
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .preferredColorScheme(impostazioni.opzioni.getTheme())
    }

    // MARK: - Sfondo tinto dal colore della slide corrente

    var sfondo: some View {
        let lista = slide
        let c = lista[min(pagina, lista.count - 1)].colore
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
        .clipShape(RoundedRectangle(cornerRadius: 20))
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

    var sezioneCarosello: some View {
        let lista = slide
        return TabView(selection: $pagina) {
            ForEach(Array(lista.enumerated()), id: \.offset) { indice, s in
                cardSlide(s)
                    .tag(indice)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 290)
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
            VStack(alignment: .leading, spacing: 8) {
                Text(s.titolo)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.leading)
                Text(s.sottotitolo)
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            Image(systemName: s.icona)
                .font(.system(size: 70))
                .foregroundStyle(.white.opacity(0.35))
        }
        .padding(20)
        .background(s.colore.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal)
        .padding(.bottom, 30)
    }

    // MARK: - Confronta + Importa

    var sezioneAzioniBuild: some View {
        HStack(spacing: 12) {
            Button {
                // Azione confronta (da fare: serve una schermata nuova)
            } label: {
                cardAzione(titolo: "Confronta",
                           sottotitolo: "Due build affiancate",
                           icona: "rectangle.split.2x1.fill",
                           colore: .purple)
            }
            .buttonStyle(.plain)
            .disabled(buildStore.savedBuilds.count < 2)
            .opacity(buildStore.savedBuilds.count < 2 ? 0.5 : 1)

            Button {
                // Azione importa
            } label: {
                cardAzione(titolo: "Importa",
                           sottotitolo: "Da file",
                           icona: "square.and.arrow.down.fill",
                           colore: .blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }

    private func cardAzione(titolo: String, sottotitolo: String,
                            icona: String, colore: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icona)
                .font(.title2)
                .foregroundStyle(colore)
            VStack(alignment: .leading, spacing: 2) {
                Text(titolo)
                    .font(.headline)
                Text(sottotitolo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(colore.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    // MARK: - Esporta (lista neutra)

    var sezioneEsporta: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Esporta")
                .font(.headline)
                .padding(.horizontal)

            if buildStore.savedBuilds.isEmpty {
                Text("Quando salverai una build potrai esportarla da qui.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(buildStore.savedBuilds.enumerated()), id: \.offset) { _, build in
                        Button {
                            // Azione esporta
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(build.nome)
                                        .font(.subheadline.bold())
                                    Text("Tocca per esportare")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.forward.app")
                                    .font(.title3)
                                    .foregroundStyle(.orange)
                            }
                            .padding(14)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
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
