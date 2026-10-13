import SwiftUI

struct ComponentePC: Identifiable {
    let id = UUID()
    let nome: String
    let immagine: String
    var colore: Color = .gray
}


struct BuildPcView: View {
    @State private var apriDettaglio = false
    @State private var componenteSelezionato:ComponentePC?
    @State var testo: String = ""
    @State var risultati: [Risultato] = []
    
    let componenti: [ComponentePC] = [
        ComponentePC(nome: "CPU", immagine: "cpu"),
        ComponentePC(nome: "Motherboard", immagine: "rectangle.3.group"),
        ComponentePC(nome: "GPU", immagine: "display"),
        ComponentePC(nome: "RAM", immagine: "memorychip"),
        ComponentePC(nome: "Power Supply", immagine: "powerplug"),
        ComponentePC(nome: "Storage", immagine: "internaldrive"),
        ComponentePC(nome: "Case", immagine: "pc", colore: .blue)
    ]
    
    var body: some View {
        NavigationStack{
            ScrollView{
                LazyVStack(spacing: 16){
                    ForEach(componenti) { comp in
                        ComponentCardView(componente:comp){
                            componenteSelezionato = comp
                            apriDettaglio = true
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top,16)
            }
            .navigationTitle("Crea la tua build")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Salva Build", action: { })
                .accentColor(.pink)
            )
            .navigationDestination(isPresented: $apriDettaglio) {
                    components()
                    .font(.title)
            }
            
        }
        NavBar(placeholder: "Cerca componenti",
                cerca: [],
                style: .build,
                testo: $testo,
                risultati: $risultati)
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
                    Text("Seleziona il componente")
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
