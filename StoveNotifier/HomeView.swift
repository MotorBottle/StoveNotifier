//
//  HomeView.swift
//  StoveNotifier
//
//  Created by MotorBottle on 2023/3/12.
//

import Foundation
import SwiftUI

struct HomeView: View {
//    @ObservedObject var deviceStore: DeviceStore
    @EnvironmentObject var deviceStore: DeviceStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(deviceStore.devices) { device in
                        NavigationLink(destination: SettingsView()) {
                            DeviceTileView(device: device)
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarItems(trailing:
                NavigationLink(destination: AddDeviceView()) {
                    Image(systemName: "plus")
                }
                .environmentObject(deviceStore)
            )
        }
    }
}
