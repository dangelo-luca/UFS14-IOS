//
//  BuildPcView.swift
//  EsameIOS
//
//  Created by d14 on 13/10/26.
//

import SwiftUI

struct BuildPcView: View {
    @State private var apriDettaglio = false
    var body: some View {
        NavigationStack{
            VStack(spacing: 26) {
                ScrollView{
                    HStack{
                        Button(action: {apriDettaglio = true}) {
                            VStack(alignment: .leading, spacing: 4){
                                HStack{
                                    Rectangle().frame(width: 70,height: 70).padding()
                                    
                                    Text("CPU").font(.largeTitle)
                                }
                                
                                HStack{
                                    Image(systemName: "plus")
                                    Text("Seleziona il componente")
                                }
                                
                            }.foregroundColor(Color.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(Color.blue))
                        }
                        
                    }
                    Button(action: {apriDettaglio = true}) {
                        VStack(alignment: .leading, spacing: 4){
                            HStack{
                                Rectangle().frame(width: 70,height: 70).padding()
                                Text("Motherboard").font(.largeTitle)
                            }
                            HStack{
                                Image(systemName: "plus")
                                Text("Seleziona il componente")
                            }
                        }.foregroundColor(Color.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color.blue))
                    }
                    
                    Button(action: {apriDettaglio = true}) {
                        VStack(alignment: .leading, spacing: 4){
                            HStack{
                                Rectangle().frame(width: 70,height: 70).padding()
                                Text("GPU").font(.largeTitle)
                            }
                            HStack{
                                Image(systemName: "plus")
                                Text("Seleziona il componente")
                            }
                        }.foregroundColor(Color.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color.blue))
                    }
                    
                    Button(action: {apriDettaglio = true}) {
                        VStack(alignment: .leading, spacing: 4){
                            HStack{
                                Rectangle().frame(width: 70,height: 70).padding()
                                Text("RAM").font(.largeTitle)
                            }
                            HStack{
                                Image(systemName: "plus")
                                Text("Seleziona il componente")
                            }
                        }.foregroundColor(Color.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color.blue))
                    }
                    
                    Button(action: {apriDettaglio = true}) {
                        VStack(alignment: .leading, spacing: 4){
                            HStack{
                                Rectangle().frame(width: 70,height: 70).padding()
                                Text("UPS").font(.largeTitle)
                            }
                            HStack{
                                Image(systemName: "plus")
                                Text("Seleziona il componente")
                            }
                        }.foregroundColor(Color.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color.blue))
                    }
                    
                }.font(.title)
                    .padding(.top,25)
                    .navigationBarTitle(Text("Crea la tua build"),displayMode: .inline)
                    .navigationBarItems(leading: Button(action: { }) {
                        Image(systemName: "chevron.backward.circle.fill")
                    }.accentColor(.gray).font(.title)
                                        , trailing: Button("Salva Build", action: { })
                        .accentColor(.pink)
                    )
                
                    .navigationDestination(isPresented: $apriDettaglio) {
                        components()
                    }
            }
        }
    }
}

#Preview {
    BuildPcView()
}
