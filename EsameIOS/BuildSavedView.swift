import SwiftUI

struct BuildSavedView: View {
    @Environment(BuildManager.self) private var buildStore
    @ObservedObject private var impostazioni = UserSettings.shared
    @State private var stackID = UUID()
    @State private var mostraLogin = false

    var body: some View {
        Group {
            if !impostazioni.isLogged {
                // STATO 1: Utente non loggato
                ContentUnavailableView {
                    Label("Accesso Richiesto", systemImage: "person.crop.circle.badge.exclamationmark")
                } description: {
                    Text("Effettua l'accesso per visualizzare e salvare le tue configurazioni.")
                } actions: {
                    Button("Accedi o Registrati") {
                        mostraLogin = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                }
            } else if buildStore.buildUtenteCorrente.isEmpty {
                // STATO 2: Loggato ma nessuna build creata
                ContentUnavailableView(
                    "Nessuna build salvata",
                    systemImage: "desktopcomputer",
                    description: Text("Crea e salva una nuova configurazione per vederla apparire qui.")
                )
            } else {
                // STATO 3: Loggato con build salvate
                List {
                    ForEach(buildStore.buildUtenteCorrente) { build in
                        NavigationLink {
                            BuildDetailView(build: build)
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "desktopcomputer")
                                    .font(.title2)
                                    .foregroundColor(.pink)
                                    .frame(width: 44, height: 44)
                                    .background(Color.pink.opacity(0.12), in: Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(build.nome)
                                        .font(.headline)
                                    Text("\(build.componenti.count) componenti")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(build.totale, format: .currency(code: "EUR"))
                                    .font(.subheadline.weight(.bold))
                                    .monospacedDigit()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { indexSet in
                        buildStore.eliminaBuildUtente(at: indexSet)
                    }
                }
                .listStyle(.insetGrouped)
                .contentMargins(.bottom, 90, for: .scrollContent)
            }
        }
        .navigationTitle("Build salvate")
        .id(stackID)
        .onChange(of: impostazioni.user_id) { _, _ in
            stackID = UUID() // Forza il refresh quando l'utente fa login/logout
        }
        .onChange(of: buildStore.savedBuilds.count) { _, _ in
            stackID = UUID()
        }
        .sheet(isPresented: $mostraLogin) {
            NavigationStack {
                AuthView()
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

#Preview {
    NavigationStack {
        BuildSavedView()
    }
    .environment(BuildManager())
}
