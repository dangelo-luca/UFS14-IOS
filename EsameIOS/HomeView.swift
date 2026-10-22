import SwiftUI

// MARK: - Modelli (dati di esempio)

struct Componente: Identifiable {
    let id = UUID()
    let nome: String
}

// Slide del carosello: ognuna ha il suo colore che tinge lo sfondo
struct SlideCarosello: Identifiable {
    let id = UUID()
    let titolo: String
    let sottotitolo: String
    let icona: String
    let colore: Color
    let coloreTesto: Color
}

// I 3 filtri della sezione Componenti
enum FiltroComponenti: String, CaseIterable {
    case prezzoBasso = "Prezzo più basso"
    case prezzoAlto = "Prezzo più alto"
    case piuAcquistati = "Preferiti / più acquistati"
}

// MARK: - Home

struct HomeView: View {
    @State var filtro: FiltroComponenti = .piuAcquistati   // default: il 3°
    @State var pagina: Int = 0                              // slide corrente del carosello
   
    // Sezione 1: carosello (il colore di sfondo cambia con la slide)
    let slide = [
        SlideCarosello(titolo: "Offerte", sottotitolo: "-20% su schede video",
                       icona: "tag.fill", colore: .red, coloreTesto: .white),
        SlideCarosello(titolo: "I più acquistati", sottotitolo: "I componenti preferiti dagli utenti",
                       icona: "star.fill", colore: .blue, coloreTesto: .white),
        SlideCarosello(titolo: "Componenti più costosi", sottotitolo: "Il top di gamma",
                       icona: "eurosign.circle.fill", colore: .yellow, coloreTesto: .black),
        SlideCarosello(titolo: "Componenti più efficienti", sottotitolo: "Più prestazioni, meno consumi",
                       icona: "leaf.fill", colore: .green, coloreTesto: .white)
    ]

    // Sezione 3: componenti (i primi 10 secondo il filtro)
    @State var componenti: [Componente] = (1...10).map { Componente(nome: "Componente \($0)") }

    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .top) {
                sfondo

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        sezioneCarosello
                        sezioneBuild
                        sezioneComponenti
                    }
                    .padding(.top, 8)
                }
            }
        }
    }

    // MARK: - Sfondo colorato con effetto sfocatura (cambia con la slide)
    var sfondo: some View {
        let c = slide[pagina].colore
        return ZStack(alignment: .top) {
            LinearGradient(colors: [c.opacity(0.55), c.opacity(0.0)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 420)

            Circle()
                .fill(c.opacity(0.5))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: -90, y: -70)

            Circle()
                .fill(c.opacity(0.4))
                .frame(width: 220, height: 220)
                .blur(radius: 60)
                .offset(x: 120, y: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.6), value: pagina)
    }

    // MARK: - Sezione 1: carosello (rosso / blu / giallo / verde)
    var sezioneCarosello: some View {
        TabView(selection: $pagina) {
            ForEach(Array(slide.enumerated()), id: \.element.id) { indice, s in
                ZStack(alignment: .bottomTrailing) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(s.titolo)
                            .font(.title2)
                            .bold()
                        Text(s.sottotitolo)
                            .font(.subheadline)
                    }
                    .foregroundStyle(s.coloreTesto)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                    Image(systemName: s.icona)
                        .font(.system(size: 60))
                        .foregroundStyle(s.coloreTesto.opacity(0.35))
                }
                .padding(20)
                .background(s.colore.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding(.horizontal)
                .padding(.bottom, 30)       // spazio per i puntini della pagina
                .tag(indice)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 240)
    }

    // MARK: - Sezione 2: Ultima Build + Test Build
    var sezioneBuild: some View {
        HStack(alignment: .top, spacing: 16) {
            cartaBuild(titolo: "Ultima Build",
                       nome: "Build Gaming",
                       dettaglio: "8 componenti",
                       colore: .blue)
            cartaBuild(titolo: "Test Build",
                       nome: "Build Test",
                       dettaglio: "6 componenti",
                       colore: .green)
        }
        .padding(.horizontal)
    }

    func cartaBuild(titolo: String, nome: String, dettaglio: String, colore: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titolo)
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "desktopcomputer")
                    .font(.title)
                Spacer()
                Text(nome).font(.headline)
                Text(dettaglio).font(.caption)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .aspectRatio(1, contentMode: .fit)
            .background(
                LinearGradient(colors: [colore.opacity(0.95), colore.opacity(0.45)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }

    // MARK: - Sezione 3: componenti con filtro
    var sezioneComponenti: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Componenti")
                    .font(.title2)
                    .bold()

                // Filtro selezionabile
                Menu {
                    Picker("Filtro", selection: $filtro) {
                        ForEach(FiltroComponenti.allCases, id: \.self) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                } label: {
                    Label(filtro.rawValue, systemImage: "line.3.horizontal.decrease.circle")
                        .font(.subheadline)
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(componenti) { c in
                    VStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.25))
                            .frame(height: 80)
                        Text(c.nome)
                            .font(.caption)
                    }
                }
            }
        }
        .foregroundStyle(.white)
        .tint(.white)
        .padding()
        // Contenitore viola sfumato rosa
        .background(
            LinearGradient(colors: [Color.purple, Color.pink.opacity(0.85)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal)
        // Quando cambia il filtro (e all'apertura) carica i primi 10
        .onChange(of: filtro) { _, nuovo in
            caricaComponenti(nuovo)
        }
        .onAppear {
            caricaComponenti(filtro)
        }
    }

    // Prende i primi 10 componenti in base al filtro: per ora vuota
    func caricaComponenti(_ filtro: FiltroComponenti) {

    }
}

// La barra vive in MainTabView, quindi la preview parte da lì
#Preview {
    MainTabView()
}
