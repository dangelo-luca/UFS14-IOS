//
//  NavBarStyle.swift
//  EsameIOS
//
//  Created by d13 on 13/10/26.
//


import SwiftUI

// Stile della barra: con il pulsante + oppure senza
enum NavBarStyle {
    case conPiu
    case senzaPiu
}

// Un risultato della ricerca
struct Risultato: Identifiable {
    let id = UUID()
    let categoria: String   // nome del file json (es. "cpu")
    let nome: String        // campo "name" dell'elemento
}

struct NavBar: View {
    var placeholder: String
    var cerca: [String]                 // file json in cui cercare, es. ["cpu", "case"]
    var style: NavBarStyle              // .conPiu oppure .senzaPiu
    @Binding var testo: String
    @Binding var risultati: [Risultato] // risultati della ricerca
    @Binding var isPressed2: Bool       // pulsante +

    var body: some View {
        HStack {
            // Pulsante SALVATI (rotondo, grigio) -> pagina build salvate
            NavigationLink(destination: BuildSalvateView()) {
                Image(systemName: "bookmark.fill")
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Salvati")

            // Barra di ricerca
            HStack {
                TextField(placeholder, text: $testo)
                Image(systemName: "magnifyingglass")
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(25)

            // Pulsante + (solo con style .conPiu)
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

    // Cerca solo nei file json indicati in "cerca"
    func cercaNeiFile(_ query: String) -> [Risultato] {
        if query.isEmpty { return [] }
        var trovati: [Risultato] = []

        for file in cerca {
            // i file sono nella cartella "json" (se non la trova, prova senza cartella)
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