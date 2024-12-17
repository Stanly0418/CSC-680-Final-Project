//
//  GuestLoginView.swift
//  CarNest
//
//  Created by on 15/12/2024.
//

import Foundation
import SwiftUI

struct GuestDetails: Hashable {
    let name: String
    let id: Int
}

struct GuestLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var loggedInGuestDetails: GuestDetails?
    @State private var navigateToDashboard: Bool = false
    @State private var isProcessing: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Guest Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)

                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .disabled(isProcessing)
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("Password")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isProcessing)
                }
                .padding(.horizontal)

                Button(action: {
                    if email.isEmpty || password.isEmpty {
                        alertMessage = "Please enter both email and password."
                        showingAlert = true
                    } else {
                        login(email: email, password: password)
                    }
                }) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        Text(isProcessing ? "Logging In..." : "Log In")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(isProcessing ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
                .disabled(isProcessing)
                .padding(.top)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

                NavigationLink(
                    destination: GuestDashboardView(guestName: loggedInGuestDetails?.name ?? "", guestId: loggedInGuestDetails?.id ?? -1),
                    isActive: $navigateToDashboard
                ) {
                    EmptyView()
                }

                NavigationLink(destination: GuestSignUpView()) {
                    Text("Don't have an account? Sign Up")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }

                Spacer()
            } .navigationBarBackButtonHidden(true)
        }
    }

    func login(email: String, password: String) {
        isProcessing = true
        guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/users") else {
            alertMessage = "Invalid API URL."
            showingAlert = true
            isProcessing = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isProcessing = false
            }
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    alertMessage = "Network error: \(error?.localizedDescription ?? "Unknown error")"
                    showingAlert = true
                }
                return
            }

            if let users = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                if let user = users.first(where: {
                    $0["email"] as? String == email &&
                    $0["password"] as? String == password &&
                    $0["role"] as? String == "Guest"
                }) {
                    DispatchQueue.main.async {
                        let name = user["name"] as? String ?? "Guest"
                        let id = Int(user["id"] as? String ?? "-1") ?? -1
                        loggedInGuestDetails = GuestDetails(name: name, id: id)
                        alertMessage = "Login successful! Welcome, \(name)."
                        showingAlert = false
                        navigateToDashboard = true
                    }
                } else {
                    DispatchQueue.main.async {
                        alertMessage = "Invalid credentials. Please try again."
                        showingAlert = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    alertMessage = "Failed to parse user data."
                    showingAlert = true
                }
            }
        }.resume()
    }
}

struct GuestLoginView_Previews: PreviewProvider {
    static var previews: some View {
        GuestLoginView()
    }
}
