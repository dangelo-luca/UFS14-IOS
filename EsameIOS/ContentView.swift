import SwiftUI

struct ContentView: View {
    @State var testo: String = ""
    @State var risultati: [Risultato] = []
    @State var isPressed2: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                // Lista risultati (opzionale, per vedere che la ricerca funziona)
                List(risultati) { r in
                    Text("\(r.categoria): \(r.nome)")
                }

                NavBar(placeholder: "Cerca",
                       cerca: ["cpu", "case"],
                       style: .conPiu,
                       testo: $testo,
                       risultati: $risultati,
                       isPressed2: $isPressed2)
            }
        }
    }
}

#Preview {
    components()
}
