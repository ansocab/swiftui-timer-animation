//
//  ContentView.swift
//  timerex
//
//  Created by Ahmet Ceylan on 28.03.2020.
//  Copyright © 2020 bernap. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    var hours = Array(0...23)
    var minutes = Array(0...59)
    var seconds = Array(0...59)
    
    @State private var timer: Timer?
    @State private var selectedHours = 0
    @State private var selectedMins = 0
    @State private var selectedSecs = 0
    @State private var showButton = false
    
    @State private var totalSecsAtStart = 0
    @State private var ellipseOneWidth: CGFloat = 400
    @State private var ellipseOneHeight: CGFloat = 300
    @State private var ellipseTwoWidth: CGFloat = 0
    @State private var ellipseTwoHeight: CGFloat = 0
    @State private var maxWidth: Double = 400
    @State private var maxHeight: Double = 300
    
    @State private var position: CGSize = CGSize(width: 0, height: -330)
    @State private var repeatAnimation: Int = 1
    
    func calculate() -> Int {
        let totalsecs = self.selectedSecs + self.selectedMins*60 + self.selectedHours*3600
        return totalsecs
    }
    
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Picker(selection: self.$selectedHours, label: Text("Hours")) {
                            ForEach(0..<self.hours.count) {
                                Text("\(self.hours[$0]) hours")
                            }
                        }
                            
                        .frame(maxWidth: geometry.size.width / 3)
                        .clipped()
                        .opacity(self.showButton ? 0 : 1)
                        
                        Picker(selection: self.$selectedMins, label: Text("Mins")) {
                            ForEach(0..<self.minutes.count) {
                                Text("\(self.minutes[$0]) mins")
                            }
                        }
                            
                        .frame(maxWidth: geometry.size.width / 3)
                        .clipped()
                        .opacity(self.showButton ? 0 : 1)
                        
                        Picker(selection: self.$selectedSecs, label: Text("Secs")) {
                            ForEach(0..<self.seconds.count) {
                                Text("\(self.seconds[$0]) secs")
                            }
                        }
                            
                        .frame(maxWidth: geometry.size.width / 3)
                        .clipped()
                        .opacity(self.showButton ? 0 : 1)
                    }
                }
                
                ZStack {
                    dropView(
                        animation: .easeIn(duration: 5.0), position: $position, repeatAnimation: $repeatAnimation
                    )
                        .opacity(self.showButton ? 1 : 0)
                    
                    VStack {
                        
                        Ellipse()
                            .frame(width: ellipseOneWidth, height: ellipseOneHeight, alignment: .center)
                            .foregroundColor(.green)
                            .shadow(radius: 4)
                            .opacity(self.showButton ? 1 : 0)
                            .animation(Animation
                                .easeInOut(duration: 1.5))
                        
                        Spacer()
                        
                        Ellipse()
                            .frame(width: ellipseTwoWidth, height: ellipseTwoHeight, alignment: .center)
                            .foregroundColor(.green)
                            .shadow(radius: 4)
                            .opacity(self.showButton ? 1 : 0)
                            .animation(Animation
                                .easeInOut(duration: 1.5))
                    }
                }
            }
            
            HStack{
                
                Text("\(calculate()/3600,specifier: "%02d") :")
                    .font(.largeTitle)
                
                Text("\((calculate() / 60) % 60,specifier: "%02d") :")
                    .font(.largeTitle)
                
                Text("\(calculate() % 60,specifier: "%02d")")
                    .font(.largeTitle)
            }
            
            HStack {
                ZStack {
                    Button(action: {
                        self.totalSecsAtStart = self.calculate()
                        self.position = CGSize(width: 0, height: 330)
                        self.repeatAnimation = Int(self.totalSecsAtStart/5)
                        
                        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                            self.selectedSecs -= 1
                            if self.calculate() <= 0 {
                                self.timer?.invalidate()
                                self.selectedSecs = 0
                                self.selectedMins = 0
                                self.selectedHours = 0
                                self.ellipseOneWidth = 0
                                self.ellipseOneHeight = 0
                                self.ellipseTwoWidth = 400
                                self.ellipseTwoHeight = 300
                                
                            }
                            if self.calculate() > 0 {
                                self.ellipseOneWidth -= CGFloat(self.maxWidth / Double(self.totalSecsAtStart))
                                self.ellipseOneHeight -= CGFloat(self.maxHeight / Double(self.totalSecsAtStart))
                                self.ellipseTwoWidth += CGFloat(self.maxWidth / Double(self.totalSecsAtStart))
                                self.ellipseTwoHeight += CGFloat(self.maxHeight / Double(self.totalSecsAtStart))
                            }
                        }
                        withAnimation(){
                            self.showButton.toggle()}
                    }) {
                        Text("Start")
                            .font(.headline)
                        
                    }
                    .opacity(showButton ? 0 : 1)
                    
                    Button(action: {
                        self.timer?.invalidate()
                        self.maxWidth = Double(self.ellipseOneWidth)
                        self.maxHeight = Double(self.ellipseOneHeight)
                        withAnimation(){
                            self.showButton = false}
                    }) {
                        Text("Pause")
                            .font(.headline)
                    }
                        
                    .opacity(showButton ? 1 : 0)
                }
                
                Button(action: {
                    self.timer?.invalidate()
                    self.selectedHours = 0
                    self.selectedMins = 0
                    self.selectedSecs = 0
                    self.ellipseOneWidth = 400
                    self.ellipseOneHeight = 300
                    self.ellipseTwoWidth = 0
                    self.ellipseTwoHeight = 0
                    self.maxWidth = 400
                    self.maxHeight = 300
                    self.position = CGSize(width: 0, height: -330)
                    self.showButton = false
                }) {
                    Text("Reset")
                        .font(.headline)
                }
            }
        }
    }
}

struct dropView: View {
    let animation: Animation
    @Binding var position: CGSize
    @Binding var repeatAnimation: Int
    
    var body: some View {
        ZStack {
            Ellipse()
                .frame(width: 36, height: 48)
                .foregroundColor(.green)
                .shadow(radius: 4)
                .offset(position)
                .animation(animation .repeatCount((repeatAnimation), autoreverses: false).speed(1))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
