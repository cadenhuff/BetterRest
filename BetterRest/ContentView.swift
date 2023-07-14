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
        NavigationView{
            Form{
                VStack(alignment: .leading, spacing: 0){
                    Text("When would you like to wakeup?")
                        .font(.headline)
                    
                    DatePicker("Please Enter a Time", selection: $wakeUp,displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("Desired Amount of Sleep?")
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step:0.25)
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("How many cups of Coffee a day?")
                    
                    Stepper(coffeeAmount == 1 ? "1 cup" :
                                "\(coffeeAmount) cups", value:$coffeeAmount, in: 1...20, step: 1)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar(){
                Button("Calculate", action:calulateBedTime)
                
            }
            .alert(alertTitle, isPresented: $showingAlert){
                Button("OK"){}
            }  message: {
                Text(alertMessage)
            }

        }

    }
    
    func calulateBedTime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minutes = (components.hour ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }
        catch{
            alertTitle = "Error"
            alertMessage = "Sorry there was an error"
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
