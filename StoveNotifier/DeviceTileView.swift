//
//  DeviceTileView.swift
//  StoveNotifier
//
//  Created by MotorBottle on 2023/3/12.
//

import SwiftUI

struct DeviceTileView: View {
    let device: Device
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color(.systemGray6))
            
            HStack {
                VStack(alignment: .leading) {
//                    Image(systemName: device.iconName)
                    Image(systemName: "stove")
                        .font(.system(size: 32))
                        .foregroundColor(.accentColor)
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text(device.name)
                            .font(.headline)
//                        Text(device.status)
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
        .onLongPressGesture {
            // Show device settings
        }
    }
}
