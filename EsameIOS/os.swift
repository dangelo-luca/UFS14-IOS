//
//  ContentView.swift
//  EsameIOS
//
//  Created by s17 on 06/10/26.
//

import SwiftUI

struct os: View {
    @State private var os: [Os] = []
    var body: some View {
        VStack {
            Text("PcPartPicker")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.red)
            
            ScrollView{
                
                ForEach(os) { Os in
                    VStack(){
                        
                        HStack{
                            
                            Image("WindowsImage").resizable().frame(width: 75, height: 80).padding()
                            
                            Spacer()
                            
                            VStack{
                                
                                Spacer()
                                
                                HStack{
                                    
                                    Text(Os.name).bold().font(.title3)
                                    
                                    Spacer()
                                    
                                }
                                
                                Spacer()
                                
                                HStack {
                                    
                                    Text("prezzo: \(String(format:"%.2f",Os.price ?? 0.00))€")
                                    
                                    Spacer()

                                }
                                Spacer()
                            }
                            
                        }
                        
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
            self.os = caricaJson("os.json")
        }
    }
}

#Preview {
    os()
}
