//
//  ContentView.swift
//  Swiftuiprova
//
//  Created by s6 on 06/10/26.
//

import SwiftUI



struct components: View {
    var body: some View {
        ScrollView {
            /*VStack(){
             HStack{
             Image(systemName: "square").resizable().frame(width: 125, height: 125)
             Spacer()
             Text("Motherboard incredibile").bold().font(.title3)
             }
             HStack{
             VStack{
             Text("Socket: Qualcosa")
             Spacer()
             Text("Wattaggio: 2W")
             }.frame(maxHeight: 60)
             Spacer()
             VStack{
             Text("Funziona: No")
             Spacer()
             }.frame(maxHeight: 60)
             Spacer()
             VStack {
             Text("Esplode: Si")
             Spacer()
             }.frame(maxHeight: 60)
             }
             HStack{
             Spacer()
             Text("Prezzo: 2 miliardi€")
             }
             }.frame(maxWidth: .infinity)
             .padding(20)
             .border(Color.black, width: 2)*/
            
            ProductView(nome: "Motherboard n", prezzo: 200000, details: ["Funziona":"NO", "No": "No"])
            
            ProductView(nome: "Motherboard incredibile", prezzo: 2200000, details: ["Funziona":"NO", "Socket": "Rimossa"])
            
        }
    }
}

struct ProductView : View {
    
    @State var isShowingDetails : Bool = false;
    
    var nome: String;
    var prezzo: Int;
    
    var details: [String: Any];
    
    var body : some View {
        VStack(){
            HStack{
                VStack{
                    Spacer()
                    HStack{
                        Text(nome).font(.title3).bold()
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text("Prezzo: \(prezzo)€")
                        Spacer()
                    }
                    
                    Spacer()
                }
            }.padding(2)
            
            Divider()
            
            if(isShowingDetails){
                HStack {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(details.sorted(by: {$0.key < $1.key}), id: \.key){ key, value in
                            Text("\(key): \(value)")
                        }
                    }
                    
                    Spacer()
                }.padding(.horizontal)
                
                Divider()
            }
            
            HStack{
                Spacer()
                Button(action: {isShowingDetails.toggle()}){
                    HStack {
                        Text(isShowingDetails ? "Nascondi dettagli" : "Mostra Dettagli")
                        Image(systemName: isShowingDetails ? "chevron.up" : "chevron.down")
                    }
                }
            }.foregroundColor(Color.blue)
        }.frame(maxWidth: .infinity)
            .padding()
    }
}

#Preview {
    components()
}
