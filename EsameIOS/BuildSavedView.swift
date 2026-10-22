import SwiftUI

struct BuildSavedView: View {
    @State var testo: String = ""
    @State var risultati: [Risultato] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // SEGNAPOSTO: qui vanno le build salvate
                ForEach(1...5, id: \.self) { i in
                    HStack {
                        Image(systemName: "desktopcomputer")
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text("Build salvata \(i)").font(.headline)
                            Text("0 componenti").font(.caption)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Build salvate")
        .safeAreaInset(edge: .bottom) {
            // .saved = senza il pulsante salvati a sinistra
           
        }
    }
}

#Preview {
    NavigationStack {
        BuildSavedView()
    }
}
