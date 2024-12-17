//
//  GuestDashboardView.swift
//  CarNest
//
//  Created by on 15/12/2024.
//

import Foundation
import SwiftUI

struct Vehicle: Identifiable, Decodable, Hashable {
    let id: String
    var vehicleName: String
    var vehicleType: String
    var pricePerDay: Int
    var isBooked: Bool
    var guestName: String?
    var status: String?
    var startDate: String?
    var endDate: String?
    var address: String
    var request: Bool
    var make: String
    let hostId: String
    let hostName: String
    let confirmation: Bool
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct GuestDashboardView: View {
    @State private var vehicles: [Vehicle] = []
        @State private var filteredVehicles: [Vehicle] = []
        @State private var pendingBookings: [Vehicle] = []
        @State private var confirmedBookings: [Vehicle] = []
        @State private var searchText: String = ""
        @State private var priceRange: String = ""
        @State private var startDate: String = ""
        @State private var endDate: String = ""
        @State private var make: String = ""
        @State private var navigateToResults: Bool = false
        @State private var showingAlert: Bool = false
        @State private var alertMessage: String = ""
        @State private var isLoading: Bool = false
        
        let guestName: String
        let guestId: Int

        var concatenatedGuestName: String {
            "\(guestName)\(guestId)"
        }

    var body: some View {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("Guest Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    VStack(spacing: 12) {
                        TextField("Enter location or car model", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(isLoading)

                        TextField("Start Date (YYYY-MM-DD)", text: $startDate)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(isLoading)

                        TextField("End Date (YYYY-MM-DD)", text: $endDate)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(isLoading)

                        TextField("Max Price", text: $priceRange)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(isLoading)

                        TextField("Enter Make (e.g., Honda)", text: $make)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(isLoading)

                        Button(action: {
                            filterVehicles()
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 200, height: 50)
                            } else {
                                Text("Search")
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50)
                                    .background(isLoading ? Color.gray : Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .disabled(isLoading)
                    }
                    .padding(.horizontal)

                    NavigationLink(
                        destination: SearchResultsView(
                            filteredVehicles: filteredVehicles,
                            guestName: concatenatedGuestName,
                            startDate: startDate,
                            endDate: endDate
                        ),
                        isActive: $navigateToResults
                    ) {
                        EmptyView()
                    }

                    Divider()
                        .padding(.vertical)

                    if isLoading {
                        ProgressView("Loading vehicles...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("My Bookings")
                                    .font(.headline)

                                if !pendingBookings.isEmpty {
                                    Text("Pending Bookings")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                    ForEach(pendingBookings) { booking in
                                        BookingCard(vehicle: booking, status: "Pending")
                                    }
                                }

                                if !confirmedBookings.isEmpty {
                                    Text("Confirmed Bookings")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                    ForEach(confirmedBookings) { booking in
                                        if booking.confirmation {
                                            BookingCard(vehicle: booking, status: "Booking Successful")
                                        } else {
                                            NavigationLink(
                                                destination: BookingConfirmationView(
                                                    vehicle: booking,
                                                    guestName: concatenatedGuestName,
                                                    startDate: booking.startDate ?? "",
                                                    endDate: booking.endDate ?? ""
                                                )
                                            ) {
                                                BookingCard(vehicle: booking, status: "Confirmed")
                                            }
                                        }
                                    }
                                }

                                if pendingBookings.isEmpty && confirmedBookings.isEmpty {
                                    Text("No bookings yet.")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer()
                }
                .onAppear {
                    startLiveUpdates()
                }
                .onDisappear {
                    stopLiveUpdates()
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    @State private var timer: Timer?

        func startLiveUpdates() {
            fetchVehicles()
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                fetchVehicles()
            }
        }

        func stopLiveUpdates() {
            timer?.invalidate()
            timer = nil
        }

        func fetchVehicles() {
            isLoading = true
            guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/vehicles") else {
                alertMessage = "Invalid API URL."
                showingAlert = true
                isLoading = false
                return
            }

            URLSession.shared.dataTask(with: url) { data, _, error in
                DispatchQueue.main.async {
                    isLoading = false
                    if let error = error {
                        alertMessage = "Failed to fetch vehicles: \(error.localizedDescription)"
                        showingAlert = true
                        return
                    }

                    if let data = data, let decodedVehicles = try? JSONDecoder().decode([Vehicle].self, from: data) {
                        self.vehicles = decodedVehicles
                        self.filterBookings()
                    } else {
                        alertMessage = "Failed to parse vehicles data."
                        showingAlert = true
                    }
                }
            }.resume()
        }
    func filterVehicles() {
        isLoading = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            let filtered = vehicles.filter { vehicle in
                let matchesModel = searchText.isEmpty || vehicle.vehicleName.lowercased().contains(searchText.lowercased())
                let matchesPrice = priceRange.isEmpty || vehicle.pricePerDay <= (Int(priceRange) ?? Int.max)
                let matchesMake = make.isEmpty || vehicle.make.lowercased().contains(make.lowercased())

                var matchesStartDate = true
                var matchesEndDate = true

                if let vehicleStartDateStr = vehicle.startDate,
                   let vehicleEndDateStr = vehicle.endDate,
                   let vehicleStartDate = dateFormatter.date(from: vehicleStartDateStr),
                   let vehicleEndDate = dateFormatter.date(from: vehicleEndDateStr) {
                    if let inputStartDate = dateFormatter.date(from: startDate) {
                        matchesStartDate = vehicleStartDate <= inputStartDate
                    }
                    if let inputEndDate = dateFormatter.date(from: endDate) {
                        matchesEndDate = vehicleEndDate >= inputEndDate
                    }
                }

                return matchesModel && matchesPrice && matchesMake && matchesStartDate && matchesEndDate
            }

            DispatchQueue.main.async {
                self.filteredVehicles = filtered
                isLoading = false
                if filtered.isEmpty {
                    alertMessage = "No vehicles found matching your criteria."
                    showingAlert = true
                } else {
                    navigateToResults = true
                }
            }
        }
    }

    func filterBookings() {
        pendingBookings = vehicles.filter { vehicle in
            let storedGuestName = vehicle.guestName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return storedGuestName == concatenatedGuestName && vehicle.status?.lowercased() == "pending"
        }
        
        confirmedBookings = vehicles.filter { vehicle in
            let storedGuestName = vehicle.guestName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return storedGuestName == concatenatedGuestName && vehicle.status?.lowercased() == "confirmed"
        }
    }
}

struct BookingCard: View {
    let vehicle: Vehicle
    let status: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vehicle: \(vehicle.vehicleName)")
                .font(.headline)
            Text("Price: $\(vehicle.pricePerDay)/day")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if vehicle.isBooked {
                Text("Booking Successful")
                    .font(.subheadline)
                    .foregroundColor(.green)
            } else {
                Text("Status: \(status)")
                    .font(.subheadline)
                    .foregroundColor(status == "Confirmed" ? .green : .orange)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct GuestDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        GuestDashboardView(guestName: "Abid Fareed", guestId: 1)
    }
}
