//
//  BookingConfirmationView.swift
//  CarNest
//
//  Created by on 15/12/2024.
//

import Foundation
import SwiftUI

struct BookingConfirmationView: View {
    let vehicle: Vehicle
    let guestName: String
    let startDate: String
    let endDate: String

    @State private var isBookingSuccessful = false
    @State private var isError = false
    @State private var isPaymentAlert = false
    @State private var isCancelAlert = false
    @State private var isLoading = false
    @State private var cardNumber: String = ""
    @State private var expiryDate: String = ""
    @State private var cvv: String = ""
    @Environment(\.presentationMode) var presentationMode

    var totalDays: Int {
        calculateDaysBetween(startDate: startDate, endDate: endDate)
    }

    var totalPrice: Int {
        totalDays * vehicle.pricePerDay
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Booking Confirmation")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)

            VStack(alignment: .leading, spacing: 10) {
                Text("Booking Summary")
                    .font(.headline)
                    .padding(.bottom, 10)

                Text("Vehicle: \(vehicle.vehicleName)")
                    .font(.subheadline)
                Text("Price Per Day: $\(vehicle.pricePerDay)")
                    .font(.subheadline)
                Text("Total Days: \(totalDays)")
                    .font(.subheadline)
                Text("Total Price: $\(totalPrice)")
                    .font(.headline)
                    .padding(.top, 5)
                Text("Guest: \(guestName)")
                    .font(.subheadline)
                Text("Start Date: \(startDate)")
                    .font(.subheadline)
                Text("End Date: \(endDate)")
                    .font(.subheadline)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            VStack(spacing: 12) {
                TextField("Card Number", text: $cardNumber)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)

                TextField("Expiry Date (MM/YY)", text: $expiryDate)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)

                TextField("CVV", text: $cvv)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)
            }
            .padding(.horizontal)

            Spacer()

            HStack(spacing: 20) {
                if !isBookingSuccessful {
                    Button(action: {
                        if cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty {
                            isPaymentAlert = true
                        } else {
                            confirmBooking()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Confirm")
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(isLoading ? Color.gray : Color.green)
                    .cornerRadius(8)
                    .disabled(isLoading)
                }

                Button(action: {
                    cancelBooking()
                }) {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(isLoading ? Color.gray : Color.red)
                        .cornerRadius(8)
                }
                .disabled(isLoading)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .alert(isPresented: $isBookingSuccessful) {
            Alert(
                title: Text("Success"),
                message: Text("Your booking has been confirmed!"),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert(isPresented: $isPaymentAlert) {
            Alert(
                title: Text("Payment Details Missing"),
                message: Text("Please fill in all payment fields."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $isCancelAlert) {
            Alert(
                title: Text("Booking Cancelled"),
                message: Text("Your booking request has been cancelled."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }.navigationBarBackButtonHidden(true)
    }

    func calculateDaysBetween(startDate: String, endDate: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let start = dateFormatter.date(from: startDate),
              let end = dateFormatter.date(from: endDate) else {
            return 1
        }
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 1
    }

    func confirmBooking() {
        isLoading = true
        guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/vehicles/\(vehicle.id)") else {
            isLoading = false
            isError = true
            return
        }

        let updatedVehicle: [String: Any] = [
            "isBooked": true,
            "guestName": guestName,
            "status": "Confirmed",
            "startDate": startDate,
            "endDate": endDate,
            "confirmation": true
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: updatedVehicle)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    isError = true
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    isBookingSuccessful = true
                } else {
                    isError = true
                }
            }
        }.resume()
    }

    func cancelBooking() {
        isLoading = true
        guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/vehicles/\(vehicle.id)") else {
            isLoading = false
            return
        }

        let resetVehicle: [String: Any] = [
            "isBooked": false,
            "guestName": "",
            "status": "",
            "request": false,
            "confirmation": false
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: resetVehicle)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    isCancelAlert = true
                } else {
                    isError = true
                }
            }
        }.resume()
    }
}

struct BookingConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleVehicle = Vehicle(
            id: "1",
            vehicleName: "Honda Civic",
            vehicleType: "Car",
            pricePerDay: 50,
            isBooked: false,
            guestName: nil,
            status: "",
            startDate: "2024-12-20",
            endDate: "2024-12-25",
            address: "123 Main St",
            request: true,
            make: "Honda",
            hostId: "1",
            hostName: "Nafey Ahmed",
            confirmation: false
        )
        BookingConfirmationView(
            vehicle: sampleVehicle,
            guestName: "John Doe",
            startDate: "2024-12-20",
            endDate: "2024-12-25"
        )
    }
}
