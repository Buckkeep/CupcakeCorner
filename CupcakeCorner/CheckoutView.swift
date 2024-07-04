//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Buhecha, Neeta (Trainee Engineer) on 03/07/2024.
//

import SwiftUI

struct CheckoutView: View {
    var order: Order
    
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    
    @State private var failureMessage = ""
    @State private var showingFailure = false

    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"), scale: 3) { image in
                    image
                        .resizable()
                        .scaledToFit()
                    
                } placeholder : {
                    ProgressView()
                }
                .frame(height: 233)
                
                Text("Your total cost is \(order.cost, format: .currency(code: "GBP"))")
                    .font(.title)
                
                Button("Place order") {
                    Task {
                        await placeOrder()
                    }
                }
                    .padding()
            }
        }
        .navigationTitle("Check out")
        .navigationBarTitleDisplayMode(.inline)
        .scrollBounceBehavior(.basedOnSize)
        .alert("Thank you!", isPresented: $showingConfirmation) {
            Button("OK") { }
        } message: {
            Text(confirmationMessage)
        }
        .alert("Something went wrong!", isPresented: $showingFailure) {
            Button("OK") { }
        } message: {
            Text(failureMessage)
        }
    }
    
    func placeOrder() async {
        // convert current order object to JSON to send to internet
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }
        // how to send via networking call - use url request
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
                      
        // run request and process response
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            
            let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
            confirmationMessage = "Your order for \(decodedOrder.quantity) \(Order.types[decodedOrder.type].lowercased()) cupcakes is on the way!"
            showingConfirmation = true
        } catch {
            print("Check out failed: \(error.localizedDescription)")
            failureMessage = "\(error.localizedDescription)"
            showingFailure = true
        }
    }
}

#Preview {
    CheckoutView(order: Order())
}
