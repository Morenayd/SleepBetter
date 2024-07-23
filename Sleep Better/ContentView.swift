//
//  ContentView.swift
//  Sleep Better
//
//  Created by Jesutofunmi Adewole on 14/02/2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? Date.now
        
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up? ") {
                    DatePicker("wake up time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .listRowBackground(Color.yellow)
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                .listRowBackground(Color.yellow)
                
                Section("Daily coffee intake") {
                    Picker("Coffee Amount", selection: $coffeeAmount) {
                        ForEach (1..<21) {
                            //Text($0 == 1 ? "1 cup" : "\($0) cups")
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                }
                .listRowBackground(Color.yellow)
                
                Section("Your sleeptime is: ") {
                    Text("\(sleepTime.formatted(date: .omitted, time: .shortened))")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundStyle(Color.accentColor)
                }
                .listRowBackground(Color.yellow)
            }
            .background(Color.yellow)
            .scrollContentBackground(.hidden)
            .navigationTitle("Sleep Better")
            .navigationBarTitleDisplayMode(.large)
            
        }
    }
    
    var sleepTime: Date {
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 8) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))
            return wakeUp - prediction.actualSleep
            
        } catch {
            return Date.now
        }
    }
}

#Preview {
    ContentView()
}
