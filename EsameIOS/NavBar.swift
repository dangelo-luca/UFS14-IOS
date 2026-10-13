import SwiftUI

enum NavBarStyle {
    case home    // tutto: salvati + ricerca + pulsante +
    case build   // senza il pulsante +
    case saved   // senza il pulsante salvati a sinistra
}

struct Risultato: Identifiable {
    let id = UUID()
    let categoria: String
    let nome: String
}

struct NavBar: View {
    var placeholder: String
    var cerca: [String]
    var style: NavBarStyle = .home
    @Binding var testo: String
    @Binding var risultati: [Risultato]

    var body: some View {
        HStack {
            // Pulsante SALVATI
            if style != .saved {
                NavigationLink(destination: BuildSavedView()) {
                    Image(systemName: "bookmark.fill")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Salvati")
            }

            // Barra di ricerca
            HStack {
                TextField(placeholder, text: $testo)
                Image(systemName: "magnifyingglass")
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(25)

            // Pulsante + -> BuildPcView
            if style != .build {
                NavigationLink(destination: BuildPcView()) {
                    Image(systemName: "plus")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Nuova build")
            }
        }
        // CONTENITORE arrotondato con effetto sfocatura
        .padding(.horizontal, 10)
            .padding(.vertical, 14)          // margine top e bottom dentro il contenitore
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40))
            .shadow(color: .black.opacity(0.15), radius: 20, y: 5)   // alone morbido intorno
            .padding(.horizontal)
            .padding(.bottom, 8)
            .onChange(of: testo) { _, nuovo in
                cercaNeiFile(nuovo)
        }
    }

    // Funzione di ricerca
    func cercaNeiFile(_ query: String) {

    }
}
/*@State var testo: String = ""
 @State var risultati: [Risultato] = []
 NavBar(placeholder: "Cerca componenti",
        cerca: categorie,
        style: .build,
        testo: $testo,
        risultati: $risultati)*/
