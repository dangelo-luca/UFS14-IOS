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

// MARK: - Home

struct HomeView: View {
    @State var pagina: Int = 0
    @Environment(BuildManager.self) private var buildStore
    @ObservedObject private var impostazioni = UserSettings.shared
    
    
    private var ultimaBuild: SavedBuild? {
        buildStore.savedBuilds.last
    }

   
    // Sezione 1: carosello
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

    // Lista delle tue build per la sezione "Esporta"
    @State var mieBuild: [String] = ["Build Gaming", "Build Ufficio", "Build Rendering", "Build Economica"]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                sfondo

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        sezioneCarosello
                        sezioneAzioniBuild
                        sezioneEsporta
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
        }.preferredColorScheme(impostazioni.opzioni.getTheme())
    }

    // MARK: - Sfondo colorato con effetto sfocatura
    var sfondo: some View {
        let c = slide[pagina].colore
        return ZStack(alignment: .top) {
            LinearGradient(colors: [c.opacity(0.55), c.opacity(0.0)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 480)

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

    // MARK: - Sezione 1: Carosello
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
                        .font(.system(size: 70))
                        .foregroundStyle(s.coloreTesto.opacity(0.35))
                }
                .padding(20)
                .background(s.colore.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding(.horizontal)
                .padding(.bottom, 30)
                .tag(indice)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 320)
    }

    // MARK: - Sezione 2: Ultima build + Importa (con titoli sopra e card quadrate)
    var sezioneAzioniBuild: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Ultima build")
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let build = ultimaBuild {
                    NavigationLink {
                        BuildDetailView(build: build)
                    } label: {
                        cardUltimaBuild
                    }
                    .buttonStyle(.plain)
                } else {
                    // Nessuna build salvata: card visibile ma non cliccabile
                    cardUltimaBuild
                        .opacity(0.5)
                }
            }

            // Carta 2: Importa
            VStack(alignment: .leading, spacing: 8) {
                Text("Importa")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Button {
                    // Azione
                } label: {
                    VStack {
                        Spacer()
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.system(size: 40))
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit) // Rende la card quadrata
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, y: 5)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Sezione 3: Esporta
    var sezioneEsporta: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Esporta")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(mieBuild, id: \.self) { build in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(build)
                                .font(.headline)
                            Text("Tocca per esportare")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.forward.app")
                            .font(.title2)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
            .foregroundStyle(.white)
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.3, blue: 0.25), Color.orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.horizontal)
            .shadow(color: Color.orange.opacity(0.3), radius: 10, y: 5)
        }
    }
}


private var cardUltimaBuild: some View {
    VStack {
        Spacer()
        Image(systemName: "desktopcomputer")
            .font(.system(size: 40))
        Spacer()
    }
    .foregroundStyle(.white)
    .frame(maxWidth: .infinity)
    .aspectRatio(1, contentMode: .fit)
    .background(Color(red: 0.5, green: 0.2, blue: 0.95))
    .clipShape(RoundedRectangle(cornerRadius: 25))
    .shadow(color: Color(red: 0.5, green: 0.2, blue: 0.95).opacity(0.3), radius: 10, y: 5)
}

#Preview {
    MainTabView()
}
