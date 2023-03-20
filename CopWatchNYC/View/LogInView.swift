//
//  Loginview.swift
//  copwatch
//
//  Created by Ramy on 2/23/23.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import Firebase

struct LogInView: View {
    @Binding var currentShowingView: String
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage = ""
    @State private var path = NavigationPath()
    @State private var isPasswordVisible = false
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack{
                Color("Color").edgesIgnoringSafeArea(.all)
                VStack{
                    HStack{
                        Spacer(minLength: 0)
                        Image("Main Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 350)
                        Spacer(minLength: 0)
                    }
                    .padding(.bottom, -50)
                    
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, -30)
                        .padding(.bottom, -50)
                    
                    HStack {
                        Image(systemName: "mail")
                        TextField("Email", text: $email)
                            .foregroundColor(.white)
                            .colorScheme(.dark)
                        
                        
                        Spacer()
                        
                        if(email.count != 0) {
                            
                            Image(systemName: email.isValidEmail() ? "checkmark" : "xmark")
                                .fontWeight(.bold)
                                .foregroundColor(email.isValidEmail() ? .green : .red)
                            
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .overlay{
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 2)
                            .foregroundColor(.white)
                    }
                    
                    .padding()
                    
                    
                    HStack {
                        Image(systemName: "lock")
                        
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .foregroundColor(.white)
                                .colorScheme(.dark)
                        } else {
                            SecureField("Password", text: $password)
                                .foregroundColor(.white)
                                .colorScheme(.dark)
                        }
                        
                        Spacer()
                        
                        if(password.count != 0) {
                            Image(systemName: password.isValidPassword(password) ? "checkmark" : "xmark")
                                .fontWeight(.bold)
                                .foregroundColor(password.isValidPassword(password) ? .green : .red)
                        }
                        
                        
                    }
                    .foregroundColor(.white)
                    .padding()
                    .overlay{
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 2)
                            .foregroundColor(.white)
                    }
                    
                    .padding()
                    
                    Button("Forgot Password?") {
                        if email.isEmpty {
                            let alert = UIAlertController(title: "Email Required", message: "Please enter your email address to reset your password.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                        } else {
                            Auth.auth().sendPasswordReset(withEmail: email) { error in
                                if let error = error {
                                    // Handle error
                                    print("Error sending password reset email: \(error.localizedDescription)")
                                } else {
                                    // Password reset email sent successfully
                                    let alert = UIAlertController(title: "Email Sent", message: "Password Reset Email Sent.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 5)
                    .padding(.horizontal, -72)
                    
                    
                    HStack {
                        
                        Button(action: {
                            withAnimation {
                                self.currentShowingView = "signup"
                            }
                            
                            
                        }) {
                            Text("Don't have an account?")
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 55)
                            
                        }
                        .padding(5)
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .frame(width: 5, height: 10)
                                .scaleEffect(1.5)
                            
                        }
                        
                    }
                    
                    
                    
                    
                    Spacer()
                    Spacer()
                    
                    Button(action: {
                        
                        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                            if let error = error {
                                print(error.localizedDescription)
                                
                                if (error.localizedDescription == "The password is invalid or the user does not have a password.") {
                                    errorMessage = "The email or password is invalid!"
                                } else if (error.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted.") {
                                    errorMessage = "The account does not exist!"
                                } else {
                                    return
                                }
                                
                            }
                            // if user is authorized change view to mapview
                            if let authResult = authResult {
                                let user = authResult.user
                                //print(user.uid)
                                
                                if user.isEmailVerified {
                                    errorMessage = ""
                                    path.append("NavBarView")
                                } else {
                                    errorMessage = "The email is not verified"
                                }
                                
                            }
                            
                        }
                        
                    }, label: {
                        Text("Sign in")
                            .foregroundColor(.white)
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                        
                            .background(
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(Color.black )
                            )
                            .padding(.horizontal )
                        
                    })
                    
                    Button(action: {
                        
                        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                        
                        // Create Google Sign In configuration object.
                        let config = GIDConfiguration(clientID: clientID)
                        GIDSignIn.sharedInstance.configuration = config
                        
                        // Start the sign in flow!
                        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { result, error in
                            guard error == nil else {
                                // ...
                                return
                            }
                            
                            guard let user = result?.user,
                                  let idToken = user.idToken?.tokenString
                            else {
                                // ...
                                return
                            }
                            
                            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                           accessToken: user.accessToken.tokenString)
                            
                            Auth.auth().signIn(with: credential) { result, error in
                                guard error == nil else {
                                    return
                                }
                                
                                print("Signed In")
                            }
                        }
                        
                    }) {
                        HStack {
                            Image("Google Logo")
                                .resizable()
                                .frame(width: 35.0, height: 35.0)
                            Text(" Continue with Google")
                        }
                    }
                    .foregroundColor(.white)
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    .background(
                        RoundedRectangle(cornerRadius: 100)
                            .fill(Color.black )
                    )
                    .padding(.horizontal )
                    
                    // sets path to mapview upon clicking
                    .navigationDestination(for: String.self) { view in
                        if view == "NavBarView" {
                            NavBarView()
                        }
                    }
                }
            }
        }
    }
}


