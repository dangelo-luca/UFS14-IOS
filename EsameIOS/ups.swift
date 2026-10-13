//
//  ContentView.swift
//  EsameIOS
//
//  Created by s17 on 06/10/26.
//

import SwiftUI

struct ups: View {
    @State private var ups: [Ups] = []
    var body: some View {
        VStack {
            Text("PcPartPicker")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.red)
            
            ScrollView{
                
                ForEach(ups) { Ups in
                    VStack(){
                        
                        HStack{
                            
                            VStack{
                                
                                Spacer()
                                
                                HStack{
                                    
                                    Text(Ups.name).bold().font(.title3)
                                    
                                    Spacer()
                                    
                                }
                                
                                Spacer()
                                
                                HStack {
                                    
                                    Text("prezzo: \(String(format:"%.2f",Ups.price ?? 0.00))€")
                                    
                                    Spacer()

                                }
                                Spacer()
                            }
                            
                        }.padding()
                        
                        HStack{
                            
                            
                            
                            Spacer()
                            
                            Button(action:{}){
                                Text("Mostra Dettagli")
                                Image(systemName: "chevron.down")
                            }
                            
                        }
                        
                    }.frame(maxWidth: .infinity, maxHeight: 110)
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 1)
                        .opacity(0.6)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                }
            }
        }.onAppear {
            self.ups = caricaJson("ups.json")
        }
    }
}

#Preview {
    ups()
}
