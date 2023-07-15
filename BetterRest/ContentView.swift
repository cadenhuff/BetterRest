//
//  ContentView.swift
//  BetterRest
//
//  Created by Caden Huffman on 7/11/23.
//
import CoreML
import SwiftUI


struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
        VStack{
            NavigationView{
                Form{
                    
                    Section("When would you like to wakeup?"){
                        
                        DatePicker("Please Enter a Time", selection: $wakeUp,displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    .font(.headline)
                    Section("Desired Amont of Sleep?"){
                        
                        
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step:0.25)
                    }
                    Section("How many cups of Coffee a day?"){
                        
                        
                        //Stepper(coffeeAmount == 1 ? "1 cup" :
                        //           "\(coffeeAmount) cups", value:$coffeeAmount, in: //1...20, step: 1)
                        Picker("My picker", selection: $coffeeAmount){
                            ForEach(0..<20){
                                Text($0, format: .number)
                            }
                        }
                    }
                    Section("BedTime"){
                        Text("\(calulateBedTime()) is your bedtime")
                    }
                    


                    
                }
                
                
                .navigationTitle("BetterRest")

                
            }
            


        }
                
    }

    
    func calulateBedTime() -> String{
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minutes = (components.hour ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime.formatted(date: .omitted, time: .shortened)
        }
        catch{
            alertTitle = "Error"
            alertMessage = "Sorry there was an error"
        }
        showingAlert = true
        return Date.now.formatted()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
