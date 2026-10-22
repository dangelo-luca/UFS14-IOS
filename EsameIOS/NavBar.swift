import SwiftUI

// MARK: - Schede della TabView

enum Scheda: Int, CaseIterable {
    case nuova, home, salvati, profilo

    var nome: String {
        switch self {
        case .nuova: return "Nuova build"
        case .home: return "Home"
        case .salvati: return "Salvati"
        case .profilo: return "Profilo"
        }
    }

    // Icona "vuota" (non selezionata) e "piena" (selezionata), come nell'app Orologio
    var icona: String {
        switch self {
        case .nuova: return "plus.circle"
        case .home: return "house"
        case .salvati: return "bookmark"
        case .profilo: return "person"
        }
    }

    var iconaAttiva: String {
        switch self {
        case .nuova: return "plus.circle.fill"
        case .home: return "house.fill"
        case .salvati: return "bookmark.fill"
        case .profilo: return "person.fill"
        }
    }
}

// MARK: - Schermata profilo (segnaposto)

struct ProfiloView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            Text("Profilo")
                .font(.largeTitle)
                .bold()
        }
    }
}

// MARK: - Contenitore principale: TabView + barra personalizzata

struct MainTabView: View {
    @State private var selezione: Scheda = .home
    @Namespace private var animazione

    var body: some View {
        TabView(selection: $selezione) {
            BuildPcView()
                .tag(Scheda.nuova)
                .toolbar(.hidden, for: .tabBar)   // nascondo la barra di sistema

            HomeView()
                .tag(Scheda.home)
                .toolbar(.hidden, for: .tabBar)

            BuildSavedView()
                .tag(Scheda.salvati)
                .toolbar(.hidden, for: .tabBar)

            ProfiloView()
                .tag(Scheda.profilo)
                .toolbar(.hidden, for: .tabBar)
        }
        // La barra personalizzata sta sotto a tutte le schede
        .safeAreaInset(edge: .bottom) {
            barra
        }
    }

    // MARK: - Barra a capsula (+ / home / salvati) + cerchio profilo blu

    var barra: some View {
        HStack(spacing: 10) {
            HStack(spacing: 4) {
                voce(.nuova)
                voce(.home)
                voce(.salvati)
            }
            .padding(6)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.15), radius: 20, y: 5)

            bottoneProfilo
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    // Singola icona della capsula: quella selezionata ha la "pillola" evidenziata
    func voce(_ scheda: Scheda) -> some View {
        let attiva = selezione == scheda
        return Button {
            withAnimation(.spring(duration: 0.35)) {
                selezione = scheda
            }
        } label: {
            Image(systemName: attiva ? scheda.iconaAttiva : scheda.icona)
                .font(.title3)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundStyle(attiva ? Color.primary : Color.secondary)
                .background {
                    if attiva {
                        Capsule()
                            .fill(Color.gray.opacity(0.25))
                            .matchedGeometryEffect(id: "pillola", in: animazione)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(scheda.nome)
    }

    // Cerchio blu del profilo (a destra, separato dalla capsula)
    var bottoneProfilo: some View {
        let attiva = selezione == .profilo
        return Button {
            withAnimation(.spring(duration: 0.35)) {
                selezione = .profilo
            }
        } label: {
            Image(systemName: attiva ? "person.fill" : "person")
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Circle().fill(Color.blue))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.9), lineWidth: attiva ? 3 : 0))
                .shadow(color: .black.opacity(0.15), radius: 20, y: 5)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profilo")
    }
}

#Preview {
    MainTabView()
}
