//
//  ContentView.swift
//  StoveNotifier
//
//  Created by MotorBottle on 2023/3/12.
//

import SwiftUI

struct ContentView: View {
//    @EnvironmentObject var deviceStore: DeviceStore
    @StateObject var deviceStore = DeviceStore()
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(deviceStore)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
