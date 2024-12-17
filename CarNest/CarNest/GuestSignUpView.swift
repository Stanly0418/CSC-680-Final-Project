//
//  GuestSignUpView.swift
//  CarNest
//
//  Created by on 15/12/2024.
//

import Foundation
import SwiftUI

struct GuestSignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Guest Sign-Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)

            VStack(alignment: .leading) {
                Text("Name")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("Enter your name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

            VStack(alignment: .leading) {
                Text("Email")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("Enter your email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
            }
            .padding(.horizontal)

            VStack(alignment: .leading) {
                Text("Password")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                SecureField("Enter your password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

            Button(action: {
                if name.isEmpty || email.isEmpty || password.isEmpty {
                    alertMessage = "Please fill in all the fields."
                    showingAlert = true
                } else {
                    signUp(name: name, email: email, password: password)
                }
            }) {
                Text("Sign Up")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

            NavigationLink(destination: GuestLoginView()) {
                Text("Already have an account? Log In")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }

    func signUp(name: String, email: String, password: String) {
        guard let url = URL(string: "https://675f19eb1f7ad24269979516.mockapi.io/users") else {
            alertMessage = "Invalid API URL."
            showingAlert = true
            return
        }

        let parameters: [String: String] = [
            "name": name,
            "email": email,
            "password": password,
            "role": "Guest"
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            alertMessage = "Failed to encode user data."
            showingAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    alertMessage = "Network error: \(error?.localizedDescription ?? "Unknown error")"
                    showingAlert = true
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                DispatchQueue.main.async {
                    alertMessage = "Sign-Up Successful! You can now log in."
                    showingAlert = true
                }
            } else {
                DispatchQueue.main.async {
                    alertMessage = "Sign-Up Failed. Please try again."
                    showingAlert = true
                }
            }
        }.resume()
    }
}

struct GuestSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        GuestSignUpView()
    }
}
