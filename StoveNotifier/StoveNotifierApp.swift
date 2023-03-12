//
//  StoveNotifierApp.swift
//  StoveNotifier
//
//  Created by MotorBottle on 2023/3/12.
//

import SwiftUI

class Device: Identifiable, Codable {
    var id = UUID()
    var name: String
    var deviceType: DeviceType
    var serverAddress: String
    var topic: String


    var deviceTypeString: String {
        switch deviceType {
        case .light:
            return "Light"
        case .temperature:
            return "Temperature"
        case .stoveMonitor:
            return "Stove Monitor"
        }
    }

    init(name: String, deviceType: DeviceType, serverAddress: String, topic: String) {
        self.name = name
        self.deviceType = deviceType
        self.serverAddress = serverAddress
        self.topic = topic
    }

//    enum DeviceType: String {
//        case light = "Light"
//        case temperature = "Temperature"
//        case stoveMonitor = "Stove Monitor"
//    }


    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(deviceTypeString, forKey: .deviceType)
        try container.encode(serverAddress, forKey: .serverAddress)
        try container.encode(topic, forKey: .topic)
        try container.encode(id.uuidString, forKey: .id)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case deviceType
        case serverAddress
        case topic
        case id
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
//        let deviceTypeString = try container.decode(String.self, forKey: .deviceType)
//        deviceType = DeviceType(rawValue: deviceTypeString) ?? .light
        let deviceTypeString = try container.decode(String.self, forKey: .deviceType)
        switch deviceTypeString {
            case "Light":
                deviceType = .light
            case "Temperature":
                deviceType = .temperature
            case "Stove Monitor":
                deviceType = .stoveMonitor
            default:
                throw DecodingError.dataCorruptedError(forKey: .deviceType, in: container, debugDescription: "Unknown device type")
        }
        serverAddress = try container.decode(String.self, forKey: .serverAddress)
        topic = try container.decode(String.self, forKey: .topic)
        let idString = try container.decode(String.self, forKey: .id)
        if let uuid = UUID(uuidString: idString) {
            id = uuid
        } else {
            id = UUID()
        }
    }

}


class DeviceStore: ObservableObject {
    
//    @Published var devices: [Device] = []
    @Published var devices: [Device] {
        didSet {
            // Save the devices to UserDefaults when the array is updated
            let encodedData = try? JSONEncoder().encode(devices)
            UserDefaults.standard.set(encodedData, forKey: "devices")
        }
    }

    init() {
        // Load the devices from UserDefaults when the app launches
        if let savedData = UserDefaults.standard.data(forKey: "devices"),
           let savedDevices = try? JSONDecoder().decode([Device].self, from: savedData) {
            devices = savedDevices
        } else {
            devices = []
        }
    }

    func addDevice(_ device: Device) {
        
        devices.append(device)
        
    }

    func removeDevice(_ device: Device) {
        if let index = devices.firstIndex(where: { $0.id == device.id }) {
            devices.remove(at: index)
        }
    }

    func getDevice(forID id: UUID) -> Device? {
        
        return devices.first(where: { $0.id == id })
    }
}

enum DeviceType {
    case light
    case temperature
    case stoveMonitor
}



@main
struct MyIOTApp: App {
    @StateObject var deviceStore = DeviceStore()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deviceStore)
        }
    }
}

