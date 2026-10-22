import SwiftUI

// MARK: - Modelli (dati di esempio)

struct Promo: Identifiable {
    let id = UUID()
    let titolo: String
    let descrizione: String
}

struct BuildRecente: Identifiable {
    let id = UUID()
    let nome: String
    let dettaglio: String
}

struct Componente: Identifiable {
    let id = UUID()
    let nome: String
}

// I 3 filtri della sezione Componenti
enum FiltroComponenti: String, CaseIterable {
    case prezzoBasso = "Prezzo più basso"
    case prezzoAlto = "Prezzo più alto"
    case piuAcquistati = "Preferiti / più acquistati"
}

// MARK: - Home

struct HomeView: View {
    @State var testo: String = ""
    @State var risultati: [Risultato] = []
    @State var filtro: FiltroComponenti = .piuAcquistati   // default: il 3°

    // Sezione 1: news / promo
    let promo = [
        Promo(titolo: "Offerta della settimana", descrizione: "-20% su schede video"),
        Promo(titolo: "Novità", descrizione: "Nuove CPU disponibili"),
        Promo(titolo: "Guida", descrizione: "Come scegliere la RAM")
    ]

    // Sezione 2: ultime build (2/3)
    let ultimeBuild = [
        BuildRecente(nome: "Build Gaming", dettaglio: "8 componenti"),
        BuildRecente(nome: "Build Ufficio", dettaglio: "6 componenti"),
        BuildRecente(nome: "Build Video", dettaglio: "9 componenti")
    ]

    // Sezione 3: componenti (i primi 10 secondo il filtro)
    @State var componenti: [Componente] = (1...10).map { Componente(nome: "Componente \($0)") }

    // File json in cui cerca la barra
    let categorie = ["case", "case-accessory", "case-fan", "cpu", "cpu-cooler",
                     "external-hard-drive", "fan-controller", "headphones",
                     "internal-hard-drive", "keyboard", "memory", "monitor",
                     "motherboard", "mouse", "optical-drive", "os", "power-supply",
                     "sound-card", "speakers", "thermal-paste", "ups", "video-card",
                     "webcam", "wired-network-card", "wireless-network-card"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    intestazione
                    sezionePromo
                    sezioneBuild
                    sezioneComponenti
                }
            }
            .safeAreaInset(edge: .bottom) {
                NavBar(placeholder: "Cerca componenti",
                       cerca: categorie,
                       testo: $testo,
                       risultati: $risultati)
            }
        }
    }

    // MARK: - Intestazione (titolo + cerchio)
    var intestazione: some View {
        HStack {
            Text("Home")
                .font(.largeTitle)
                .bold()
            Spacer()
            Button(action: {
                print("Profilo")
            }) {
                Image(systemName: "person.fill")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Sezione 1: news / promo (si scorre di lato)
    var sezionePromo: some View {
        TabView {
            ForEach(promo) { p in
                VStack(alignment: .leading, spacing: 8) {
                    Text(p.titolo).font(.title2).bold()
                    Text(p.descrizione)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding()
                .background(Color.pink.opacity(0.2))
                .cornerRadius(25)
                .padding(.horizontal)
            }
        }
        .tabViewStyle(.page)
        .frame(height: 200)
    }

    // MARK: - Sezione 2: ultime build
    var sezioneBuild: some View {
        VStack(alignment: .leading) {
            Text("Build")
                .font(.title2)
                .bold()
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ultimeBuild) { b in
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "desktopcomputer")
                                .font(.title)
                            Text(b.nome).font(.headline)
                            Text(b.dettaglio).font(.caption)
                        }
                        .frame(width: 160, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Sezione 3: componenti con filtro
    var sezioneComponenti: some View {
        VStack(alignment: .leading) {
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
            .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(componenti) { c in
                    VStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 80)
                        Text(c.nome)
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal)
        }
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

#Preview {
    HomeView()
}
