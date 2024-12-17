//
//  EditVehicleView.swift
//  CarNest
//
//  Created by on 16/12/2024.
//

import Foundation
import SwiftUI

struct EditVehicleView: View {
    @State var vehicle: Vehicle
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Vehicle")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Vehicle Name", text: $vehicle.vehicleName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Price Per Day", value: $vehicle.pricePerDay, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                updateVehicle()
            }) {
                Text("Save Changes")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.green)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                if alertMessage == "Vehicle updated successfully!" {
                    //presentationMode.wrappedValue.dismiss()
                }
            })
        }
        .navigationBarBackButtonHidden(true)
    }

    func updateVehicle() {
        guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/vehicles/\(vehicle.id)") else {
            alertMessage = "Invalid URL."
            showAlert = true
            return
        }

        guard !vehicle.vehicleName.isEmpty, vehicle.pricePerDay > 0 else {
            alertMessage = "Please provide valid details for the vehicle."
            showAlert = true
            return
        }

        let updatedVehicle: [String: Any] = [
            "vehicleName": vehicle.vehicleName,
            "pricePerDay": vehicle.pricePerDay
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: updatedVehicle)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = "Failed to update vehicle: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    alertMessage = "Vehicle updated successfully!"
                } else {
                    alertMessage = "Failed to update vehicle. Please try again."
                }
                showAlert = true
            }
        }.resume()
    }
}
