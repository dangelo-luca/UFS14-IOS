import SwiftUI

// MARK: - Schede della TabView

enum Scheda: Int, CaseIterable {
    case nuova, home, salvati, profilo

    var nome: LocalizedStringKey {
        switch self {
        case .nuova: return "Nuova build"
        case .home: return "Home"
        case .salvati: return "Salvati"
        case .profilo: return "Profilo"
        }
    }

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
    // Iniezione con @Observable (iOS 17+)
    @Environment(BuildManager.self) private var buildStore

    @ObservedObject private var impostazioni = UserSettings.shared
    @State private var selezione: Scheda = .home
    @State private var mostraLogin = false
    @Namespace private var animazione

    // ID per resettare la navigazione di Home e Salvati
    @State private var homeStackID = UUID()
    @State private var salvatiStackID = UUID()
    @State private var profiloStackID = UUID()

    var body: some View {
        TabView(selection: $selezione) {
            // Tab 1: Nuova build
            NavigationStack {
                BuildPcView {
                    withAnimation(.spring(duration: 0.35)) {
                        homeStackID = UUID() // Resetta la Home prima di tornarci
                        selezione = .home
                    }
                }
            }
            .tag(Scheda.nuova)
            .toolbar(.hidden, for: .tabBar)

            // Tab 2: Home
            NavigationStack {
                HomeView(
                    vaiASalvati: {
                        if impostazioni.isLogged {
                            withAnimation(.spring(duration: 0.35)) { selezione = .salvati }
                        } else {
                            mostraLogin = true
                        }
                    },
                    nuovaBuild: {
                        withAnimation(.spring(duration: 0.35)) { selezione = .nuova }
                    }
                )
            }
            .id(homeStackID) // Collega l'ID allo stack della Home
            .tag(Scheda.home)
            .toolbar(.hidden, for: .tabBar)
            
            // Tab 3: Salvati
            NavigationStack {
                BuildSavedView()
            }
            .id(salvatiStackID)
            .tag(Scheda.salvati)
            .toolbar(.hidden, for: .tabBar)

            // Tab 4: Profilo
            NavigationStack {
                Settings()
            }
            .id(profiloStackID)
            .tag(Scheda.profilo)
            .toolbar(.hidden, for: .tabBar)
        }
        .onChange(of: buildStore.savedBuilds.count) { _, _ in
            homeStackID = UUID()
            salvatiStackID = UUID()
        }
        .onChange(of: impostazioni.user_id) { _, _ in
            profiloStackID = UUID()
            salvatiStackID = UUID()
            homeStackID = UUID()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            barra
        }
        .sheet(isPresented: $mostraLogin) {
            NavigationStack {
                AuthView {
                    withAnimation(.spring(duration: 0.35)) {
                        selezione = .salvati
                    }
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

    // MARK: - Barra a capsula (+ / home / salvati) + cerchio profilo blu

    var barra: some View {
        HStack(spacing: 10) {
            HStack(spacing: 4) {
                voce(.salvati)
                voce(.home)
                voce(.nuova)
            }
            .padding(6)
            .background(.regularMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.15), radius: 20, y: 5)

            bottoneProfilo
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    func voce(_ scheda: Scheda) -> some View {
        let attiva = selezione == scheda
        return Button {
            if scheda == .salvati && !impostazioni.isLogged {
                mostraLogin = true
            } else {
                withAnimation(.spring(duration: 0.35)) {
                    selezione = scheda
                }
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
        .accessibilityLabel(Text(scheda.nome))
    }

    var bottoneProfilo: some View {
        let attiva = selezione == .profilo
        return Button {
            profiloStackID = UUID()
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
        .accessibilityLabel(Text("Profilo"))
    }
}

#Preview {
    MainTabView()
        .environment(BuildManager())
}
