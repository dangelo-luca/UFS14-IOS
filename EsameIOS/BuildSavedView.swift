import SwiftUI

struct BuildSavedView: View {
    @Environment(BuildManager.self) private var buildStore

    var body: some View {
        Group {
            if buildStore.savedBuilds.isEmpty {
                ContentUnavailableView(
                    "Nessuna build salvata",
                    systemImage: "desktopcomputer",
                    description: Text("Crea e salva una nuova configurazione per vederla apparire qui.")
                )
            } else {
                List {
                    ForEach(buildStore.savedBuilds) { build in
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
                    .onDelete(perform: buildStore.eliminaBuild)
                }
                .listStyle(.insetGrouped)
                .contentMargins(.bottom, 90, for: .scrollContent) // spazio per la barra in basso
            }
        }
        .navigationTitle("Build salvate")
    }
}
#Preview {
    NavigationStack {
        BuildSavedView()
    }
    .environment(BuildManager())
}
