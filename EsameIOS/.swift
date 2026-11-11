import SwiftUI

enum NavBarStyle {
    case conPiu
    case senzaPiu
}

struct Risultato: Identifiable {
    let id = UUID()
    let categoria: String
    let nome: String
}

struct NavBar: View {
    var placeholder: String
    var cerca: [String]
    var style: NavBarStyle
    @Binding var testo: String
    @Binding var risultati: [Risultato]
    @Binding var isPressed2: Bool

    var body: some View {
        HStack {

            NavigationLink(destination: BuildSalvateView()) {
                Image(systemName: "bookmark.fill")
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Salvati")

            HStack {
                TextField(placeholder, text: $testo)
                Image(systemName: "magnifyingglass")
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(25)

            if style == .conPiu {
                Button(action: {isPressed2.toggle()}) {
                    Image(systemName: "plus")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .onChange(of: testo) { _, nuovo in
            risultati = cercaNeiFile(nuovo)
        }
    }

    func cercaNeiFile(_ query: String) -> [Risultato] {
        if query.isEmpty { return [] }
        var trovati: [Risultato] = []

        for file in cerca {

            guard let url = Bundle.main.url(forResource: file, withExtension: "json", subdirectory: "json")
                    ?? Bundle.main.url(forResource: file, withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let elementi = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            else { continue }

            for e in elementi {
                if let nome = e["name"] as? String,
                   nome.localizedCaseInsensitiveContains(query) {
                    trovati.append(Risultato(categoria: file, nome: nome))
                }
            }
        }
        return trovati
    }
}
