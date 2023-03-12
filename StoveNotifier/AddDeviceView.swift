//
//  AddDeviceView.swift
//  StoveNotifier
//
//  Created by MotorBottle on 2023/3/12.
//

import SwiftUI

struct AddDeviceView: View {
    @EnvironmentObject var deviceStore: DeviceStore
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var deviceType: DeviceType = .light
    @State private var serverAddress: String = ""
    @State private var topic: String = ""

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
            }
                
                
            .navigationBarItems(trailing:
                Button(action: {
                    let newDevice = Device(name: name, deviceType: deviceType, serverAddress: serverAddress, topic: topic)
                    deviceStore.addDevice(newDevice)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                }
            )
            .navigationTitle("Add Device")
        }
    }
}



struct AddDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        AddDeviceView()
    }
}

