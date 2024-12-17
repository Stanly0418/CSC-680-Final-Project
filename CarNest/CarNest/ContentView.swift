//
//  ContentView.swift
//  CarNest
//
//  Created by on 15/12/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Text("CarNest - Your Travel Haven")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                Text("Choose your role")
                    .font(.headline)

                NavigationLink(destination: GuestLoginView()) {
                    HStack {
                        Image(systemName: "car")
                            .font(.system(size: 20))
                        Text("Become a Guest")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 250, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                }

                NavigationLink(destination: HostLoginView()) {
                    HStack {
                        Image(systemName: "key")
                            .font(.system(size: 20))
                        Text("Become a Host")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 250, height: 50)
                    .background(Color.green)
                    .cornerRadius(10)
                }

                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}
#Preview {
    ContentView()
}
