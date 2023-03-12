//
//  DeviceTileView.swift
//  StoveNotifier
//
//  Created by MotorBottle on 2023/3/12.
//

import SwiftUI

//struct DeviceTileView: View {
//    let device: Device
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 12)
//                .foregroundColor(Color(.systemGray6))
//
//            HStack {
//                VStack(alignment: .leading) {
////                    Image(systemName: device.iconName)
//                    Image(systemName: "stove")
//                        .font(.system(size: 32))
//                        .foregroundColor(.accentColor)
//                        .padding()
//
//                    VStack(alignment: .leading) {
//                        Text(device.name)
//                            .font(.headline)
////                        Text(device.status)
//                        Text("On")
//                            .font(.subheadline)
//                    }
//                    .padding(.bottom, 8)
//                    .padding(.leading, 16)
//                    .padding(.trailing, 16)
//                }
//
//                Spacer()
//            }
//        }
//        .frame(height: 120)
//        .padding()
//        .onLongPressGesture {
//            // Show device settings
//        }
//    }
//}

struct DeviceTileView: View {
    let device: Device
    @State private var isEditing: Bool = false // add state variable to indicate if user is editing the device info
    
    var body: some View {
        NavigationLink(destination: DeviceEditView(device: device, isEditing: $isEditing), isActive: $isEditing) {
            // content of device tile
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color(.systemGray6))
                
                HStack {
                    VStack(alignment: .leading) {
                        Image(systemName: "stove")
                            .font(.system(size: 32))
                            .foregroundColor(.accentColor)
                            .padding()
                        
                        VStack(alignment: .leading) {
                            Text(device.name)
                                .font(.headline)
                            Text("On")
                                .font(.subheadline)
                        }
                        .padding(.bottom, 8)
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                    }
                    
                    Spacer()
                }
            }
            .frame(height: 120)
            .padding()
        }
        .onTapGesture {
            isEditing = true // set editing mode to true when user taps on the device tile
        }
    }
}

struct DeviceEditView: View {
    @EnvironmentObject var deviceStore: DeviceStore
    let device: Device
    
    @Binding var isEditing: Bool // add binding to indicate if user is editing the device info
    @State private var name: String // add state variables to hold device info
    @State private var serverAddress: String
    @State private var topic: String
    @State private var deviceType: DeviceType = .light
    
    init(device: Device, isEditing: Binding<Bool>) {
        self.device = device
        self._isEditing = isEditing
        self._name = State(initialValue: device.name) // set initial values of state variables to device info
        self._serverAddress = State(initialValue: device.serverAddress)
        self._topic = State(initialValue: device.topic)
        self._deviceType = State(initialValue: device.deviceType)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Device Information")) {
                    TextField("Device Name", text: $name)
                    Picker("Device Type", selection: $deviceType) {
                        Text("Light").tag(DeviceType.light)
                        Text("Temperature").tag(DeviceType.temperature)
                        Text("StoveMonitor").tag(DeviceType.stoveMonitor)
                        Text("Other").tag("other")
                    }
                }
                
                if deviceType == .stoveMonitor {
                    Section(header: Text("MQTT Configuration")) {
                        TextField("Server Address", text: $serverAddress)
                        TextField("Subscribe Topic", text: $topic)
                    }
                }
                
//                HStack {
//                    Button("Delete") {
//                        deviceStore.removeDevice(device) // remove device from the device store
//                        isEditing = false
//                    }
//                    .foregroundColor(.red)
//                    .padding()
//                    Spacer()
//                    Button("Save") {
//                        // save device info and return to device tile view
//                        let updatedDevice = Device(name: name, deviceType: deviceType, serverAddress: serverAddress, topic: topic)
//                        deviceStore.removeDevice(device)
//                        deviceStore.addDevice(updatedDevice)
//                        isEditing = false
//                    }
//                    .padding()
//                }

                HStack {
                    Button(action: {
                        deviceStore.removeDevice(device)
                        isEditing = false
                    }, label: {
                        Text("Delete")
                            .foregroundColor(.red)
                            .padding()
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        let updatedDevice = Device(name: name, deviceType: deviceType, serverAddress: serverAddress, topic: topic)
                        deviceStore.removeDevice(device)
                        deviceStore.addDevice(updatedDevice)
                        isEditing = false
                    }, label: {
                        Text("Save")
                            .padding()
                    })
                }
                
                .navigationTitle(device.name)
            }
        }
    }
}


