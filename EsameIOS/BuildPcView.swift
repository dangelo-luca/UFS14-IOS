import SwiftUI

struct ComponentePC: Identifiable, Hashable {
    let id: UUID
    let nome: String
    var colore: Color
    
    init(id: UUID = UUID(), nome: String, colore: Color = .gray) {
        self.id = id
        self.nome = nome
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
    
    let componenti: [ComponentePC] = [
        ComponentePC(nome: "CPU"),
        ComponentePC(nome: "Motherboard"),
        ComponentePC(nome: "GPU"),
        ComponentePC(nome: "RAM"),
        ComponentePC(nome: "Power Supply"),
        ComponentePC(nome: "Storage"),
        ComponentePC(nome: "Case"),
        ComponentePC(nome: "os"),
        ComponentePC(nome: "ups")
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
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 70, height: 70)
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
