//
//  HostDashboardView.swift
//  CarNest
//
//  Created by on 16/12/2024.
//

import Foundation
import SwiftUI

struct HostDashboardView: View {
    let hostName: String
    let hostId: String

    @State private var vehicles: [Vehicle] = []
    @State private var showAddVehicleView: Bool = false
    @State private var showEditVehicleView: Vehicle?
    @State private var isAlertVisible = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome back, \(hostName)!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Here's your overview.")
                    .font(.headline)

                ScrollView {
                    ForEach(vehicles) { vehicle in
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Model and Year: \(vehicle.vehicleName)")
                                .font(.headline)
                            Text("Available: \(vehicle.startDate ?? "N/A") - \(vehicle.endDate ?? "N/A")")
                            Text("Price per day: $\(vehicle.pricePerDay)")
                            Text("Status: \(vehicle.status ?? "N/A")")
                                .foregroundColor(vehicle.status == "Pending" ? .orange : (vehicle.isBooked ? .red : .green))

                            if vehicle.status == "Pending" {
                                HStack {
                                    if vehicle.status == "Pending" {
                                        Button("Accept") {
                                            updateRequestStatus(vehicle: vehicle, newStatus: "Confirmed", reset: false)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(.green)

                                        Button("Reject") {
                                            updateRequestStatus(vehicle: vehicle, newStatus: "", reset: true)
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(.red)
                                    }
                                }
                            }

                            HStack {
                                Button("Edit") {
                                    showEditVehicleView = vehicle
                                }
                                .buttonStyle(.borderedProminent)

                                Spacer()

                                Button("Delete") {
                                    deleteVehicle(vehicle: vehicle)
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            }
                            Divider()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                    }
                }

                Button(action: {
                    showAddVehicleView = true
                }) {
                    Text("Add Vehicle")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("\tHost Dashboard")
            .onAppear(perform: fetchVehicles)
            .navigationDestination(isPresented: $showAddVehicleView) {
                AddVehicleView(hostName: hostName, hostId: hostId)
            }
            .navigationDestination(item: $showEditVehicleView) { vehicle in
                EditVehicleView(vehicle: vehicle)
            }
            .alert(isPresented: $isAlertVisible) {
                Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }.navigationBarBackButtonHidden(true)
        }
    }

    func fetchVehicles() {
        guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/vehicles") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decodedVehicles = try? JSONDecoder().decode([Vehicle].self, from: data) {
                    DispatchQueue.main.async {
                        self.vehicles = decodedVehicles.filter { $0.hostId == hostId }
                    }
                }
            }
        }.resume()
    }

    func deleteVehicle(vehicle: Vehicle) {
        guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/vehicles/\(vehicle.id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                fetchVehicles()
                alertMessage = "Vehicle deleted successfully."
                isAlertVisible = true
            }
        }.resume()
    }

    func updateRequestStatus(vehicle: Vehicle, newStatus: String, reset: Bool) {
        guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/vehicles/\(vehicle.id)") else { return }

        var updatedVehicle: [String: Any] = [:]
        if reset {
            updatedVehicle = [
                "status": "",
                "isBooked": false,
                "guestName": "",
                "request": false
            ]
        } else {
            updatedVehicle = [
                "status": newStatus,
                "isBooked": true
            ]
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: updatedVehicle)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = "Failed to update status: \(error.localizedDescription)"
                    isAlertVisible = true
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    alertMessage = reset ? "Request rejected successfully." : "Request accepted successfully."
                    isAlertVisible = true
                    fetchUpdatedVehicle(vehicleId: vehicle.id)
                } else {
                    alertMessage = "Failed to update status. Please try again."
                    isAlertVisible = true
                }
            }
        }.resume()
    }

    func fetchUpdatedVehicle(vehicleId: String) {
        guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/vehicles/\(vehicleId)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let updatedVehicle = try? JSONDecoder().decode(Vehicle.self, from: data) {
                    DispatchQueue.main.async {
                        if let index = vehicles.firstIndex(where: { $0.id == updatedVehicle.id }) {
                            vehicles[index] = updatedVehicle
                        }
                    }
                }
            }
        }.resume()
    }
}
