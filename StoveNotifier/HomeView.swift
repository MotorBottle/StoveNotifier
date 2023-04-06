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
    @State private var isPresentingAddDeviceView = false
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(deviceStore.devices) { device in
                        NavigationLink(destination: DeviceEditView(device: device, isEditing: $isEditing)) {
                            DeviceTileView(device: device)
                        }
                    }
                }
            }
//            .navigationTitle("Home")
//            .navigationBarItems(trailing:
//                NavigationLink(destination: AddDeviceView()) {
//                    Image(systemName: "plus")
//                }
//                .environmentObject(deviceStore)
//            )
            
            .navigationTitle("Home")
            .navigationBarItems(trailing:
                Button(action: {
                    isPresentingAddDeviceView = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $isPresentingAddDeviceView) {
                AddDeviceView()
                    .environmentObject(deviceStore)
            }
        }
    }
}
