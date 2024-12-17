//
//  SearchResultsView.swift
//  CarNest
//
//  Created by on 15/12/2024.
//

import Foundation
import SwiftUI
struct SearchResultsView: View {
    let filteredVehicles: [Vehicle]
    let guestName: String
    let startDate: String
    let endDate: String

    @State private var selectedVehicle: Vehicle? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(filteredVehicles) { vehicle in
                        VehicleCard(
                            vehicle: vehicle,
                            guestName: guestName,
                            startDate: startDate,
                            endDate: endDate,
                            onSelect: { selectedVehicle = $0 }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Search Results")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Vehicle.self) { vehicle in
                BookingConfirmationView(
                    vehicle: vehicle,
                    guestName: guestName,
                    startDate: startDate,
                    endDate: endDate
                )
            }.navigationBarBackButtonHidden(false)
        }
    }
}

struct VehicleCard: View {
    let vehicle: Vehicle
    let guestName: String
    let startDate: String
    let endDate: String
    let onSelect: (Vehicle) -> Void

    @State private var isRequesting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Make & Model: \(vehicle.vehicleName)")
                .font(.headline)
                .foregroundColor(.primary)
            Text("Price: $\(vehicle.pricePerDay)/day")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if vehicle.isBooked {
                Text("Already Booked")
                    .font(.subheadline)
                    .foregroundColor(.red)
            } else if vehicle.request {
                Text("Request Sent")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            } else {
                Button(action: {
                    sendBookingRequest()
                }) {
                    Text("Book this car")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(isRequesting ? Color.gray : Color.green)
                        .cornerRadius(8)
                }
                .disabled(isRequesting)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Booking Request"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }.navigationBarBackButtonHidden(true)
    }

    func sendBookingRequest() {
        isRequesting = true
        guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/vehicles/\(vehicle.id)") else {
            alertMessage = "Invalid URL."
            showAlert = true
            isRequesting = false
            return
        }

        let updatedVehicle: [String: Any] = [
            "request": true,
            "guestName": guestName,
            "startDate": startDate,
            "endDate": endDate,
            "status": "Pending"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: updatedVehicle)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isRequesting = false
                if let error = error {
                    alertMessage = "Failed to send request: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    alertMessage = "Request sent successfully!"
                    showAlert = true
                    onSelect(vehicle) 
                } else {
                    alertMessage = "Failed to send booking request."
                    showAlert = true
                }
            }
        }.resume()
    }
}
