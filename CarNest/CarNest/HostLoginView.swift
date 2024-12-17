//
//  HostLoginView.swift
//  CarNest
//
//  Created by on 15/12/2024.
//

import Foundation
import SwiftUI
struct HostDetails: Hashable {
    let name: String
    let id: String
}

struct HostLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var loggedInHostDetails: HostDetails?
    @State private var navigateToDashboard: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Host Login")
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
                        .disabled(isLoading)
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("Password")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)
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
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Log In")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(isLoading ? Color.gray : Color.green)
                .cornerRadius(10)
                .disabled(isLoading)
                .padding(.top)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

                NavigationLink(
                    destination: HostDashboardView(
                        hostName: loggedInHostDetails?.name ?? "Host",
                        hostId: loggedInHostDetails?.id ?? ""
                    ),
                    isActive: $navigateToDashboard
                ) {
                    EmptyView()
                }

                NavigationLink(destination: HostSignUpView()) {
                    Text("Don't have an account? Sign Up")
                        .font(.footnote)
                        .foregroundColor(.green)
                }

                Spacer()
            }.navigationBarBackButtonHidden(true)
        }
    }

    func login(email: String, password: String) {
        guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/users") else {
            alertMessage = "Invalid API URL."
            showingAlert = true
            return
        }

        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false 
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
                    $0["role"] as? String == "Host"
                }) {
                    DispatchQueue.main.async {
                        let name = user["name"] as? String ?? "Host"
                        let id = user["id"] as? String ?? ""
                        loggedInHostDetails = HostDetails(name: name, id: id)
                        navigateToDashboard = true
                    }
                } else {
                    DispatchQueue.main.async {
                        alertMessage = "Invalid credentials or role. Please try again."
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

struct HostLoginView_Previews: PreviewProvider {
    static var previews: some View {
        HostLoginView()
    }
}

