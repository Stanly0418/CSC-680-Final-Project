//
//  AddVehicleView.swift
//  CarNest
//
//  Created by  on 16/12/2024.
//

import Foundation
import SwiftUI
struct AddVehicleView: View {
    let hostName: String
    let hostId: String

    @State private var vehicleName = ""
    @State private var pricePerDay = ""
    @State private var startDate = ""
    @State private var endDate = ""
    @State private var vehicleType = ""
    @State private var make = ""
    @State private var address = ""
    @State private var isAlertVisible = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Add Vehicle")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack {
                TextField("Vehicle Name", text: $vehicleName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Price Per Day", text: $pricePerDay)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Start Date (YYYY-MM-DD)", text: $startDate)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("End Date (YYYY-MM-DD)", text: $endDate)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Make", text: $make)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Address", text: $address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()

            Button(action: addVehicle) {
                Text("Save Vehicle")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .padding()
        .alert(isPresented: $isAlertVisible) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }.navigationBarBackButtonHidden(true)
    }

    func addVehicle() {
        guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/vehicles") else { return }
        let newVehicle: [String: Any] = [
            "vehicleName": vehicleName,
            "pricePerDay": Int(pricePerDay) ?? 0,
            "startDate": startDate,
            "endDate": endDate,
            "vehicleType": vehicleType,
            "make": make,
            "address": address,
            "guestName":"",
            "status":"",
            "isBooked": false,
            "hostName": hostName,
            "hostId": hostId,
            "request": false
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: newVehicle)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    alertMessage = "Vehicle added successfully!"
                } else {
                    alertMessage = "Failed to add vehicle."
                }
                isAlertVisible = true
            }
        }.resume()
    }
}
