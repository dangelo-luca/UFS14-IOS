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

    // Icona "vuota" (non selezionata) e "piena" (selezionata)
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



// MARK: - Contenitore principale: TabView + barra personalizzata

struct MainTabView: View {
    @State private var selezione: Scheda = .home
    @Namespace private var animazione

    var body: some View {
        TabView(selection: $selezione) {
            NavigationStack {
                BuildPcView {
                    withAnimation(.spring(duration: 0.35)) {
                        selezione = .home
                    }
                }
            }
            .tag(Scheda.nuova)
            .toolbar(.hidden, for: .tabBar)

            NavigationStack {
                HomeView(
                    vaiASalvati: {
                        withAnimation(.spring(duration: 0.35)) { selezione = .salvati }
                    },
                    nuovaBuild: {
                        withAnimation(.spring(duration: 0.35)) { selezione = .nuova }
                    }
                )
            }
            .tag(Scheda.home)
            .toolbar(.hidden, for: .tabBar)
            
            NavigationStack {
                BuildSavedView()
            }
            .tag(Scheda.salvati)
            .toolbar(.hidden, for: .tabBar)

            NavigationStack {
                Settings()
            }
            .tag(Scheda.profilo)
            .toolbar(.hidden, for: .tabBar)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            barra
        }
    }

    // MARK: - Barra a capsula (+ / home / salvati) + cerchio profilo blu

    var barra: some View {
        HStack(spacing: 10) {
            HStack(spacing: 4) {
                voce(.salvati)
                voce(.home)
                voce(.nuova)
            }
            .padding(6)
            // più opaco di prima: le schede sotto non "sporcano" le icone
            .background(.regularMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.15), radius: 20, y: 5)

            bottoneProfilo
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
        // quando si apre la tastiera (es. barra di ricerca) la barra resta in basso
        // invece di salire sopra la tastiera e coprire i risultati
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
        .environment(BuildManager())
}
