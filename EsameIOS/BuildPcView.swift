import SwiftUI

struct ComponentePC: Identifiable, Hashable {
    let id: UUID
    let nome: String
    let immagine: String
    var colore: Color

    init(id: UUID = UUID(), nome: String, immagine: String = "square.dashed", colore: Color = .gray) {
        self.id = id
        self.nome = nome
        self.immagine = immagine
        self.colore = colore
    }

    static func == (lhs: ComponentePC, rhs: ComponentePC) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct BuildPcView: View {
    @State private var componenteSelezionato: ComponentePC?
    @State var testo: String = ""
    @State var risultati: [Risultato] = []

    let componenti: [ComponentePC] = [
        ComponentePC(nome: "CPU", immagine: "cpu"),
        ComponentePC(nome: "Motherboard", immagine: "rectangle.3.group"),
        ComponentePC(nome: "GPU", immagine: "display"),
        ComponentePC(nome: "RAM", immagine: "memorychip"),
        ComponentePC(nome: "Power Supply", immagine: "powerplug"),
        ComponentePC(nome: "Storage", immagine: "internaldrive"),
        ComponentePC(nome: "Case", immagine: "pc", colore: .blue),
        ComponentePC(nome: "os", immagine: "desktopcomputer"),
        ComponentePC(nome: "ups", immagine: "bolt.shield")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(componenti) { comp in
                        ComponentCardView(componente: comp) {
                            componenteSelezionato = comp
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            .navigationTitle("Crea la tua build")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { }) {
                        Image(systemName: "chevron.backward.circle.fill")
                    }
                    .accentColor(.gray)
                    .font(.title)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salva Build", action: { })
                        .accentColor(.pink)
                }
            }
            .navigationDestination(item: $componenteSelezionato) { componente in
                vistaDettaglio(per: componente)
            }
        }
        NavBar(placeholder: "Cerca componenti",
               cerca: [],
               style: .build,
               testo: $testo,
               risultati: $risultati)
    }

    @ViewBuilder
    private func vistaDettaglio(per componente: ComponentePC) -> some View {
        switch componente.nome.lowercased() {
        case "os":
            os()
        case "ups":
            ups()
        default:
            DettaglioComponenteView(componente: componente)
        }
    }
}

struct DettaglioComponenteView: View {
    let componente: ComponentePC

    var body: some View {
        VStack(spacing: 16) {
            Text(componente.nome)
                .font(.largeTitle)
                .bold()

            Text("Seleziona \(componente.nome)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle(componente.nome)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ComponentCardView: View {
    let componente: ComponentePC
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    Image(systemName: componente.immagine)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .frame(width: 70, height: 70)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)

                    Text(componente.nome)
                        .font(.title)
                        .bold()
                }

                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Scegli un \(componente.nome)")
                }
                .font(.subheadline)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(componente.colore)
            )
        }
    }
}

#Preview {
    BuildPcView()
}
