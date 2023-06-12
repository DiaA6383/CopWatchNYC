import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import Firebase

struct SignUpView: View {
    @Binding var currentShowingView: String // The currently displayed view
    @Binding var reportedLocations: [IdentifiablePin] // Array of reported locations
    
    @State private var path = NavigationPath() // Navigation path state
    @State private var email: String = "" // User's email
    @State private var password: String = "" // User's password
    @State private var confirmPassword: String = "" // Confirm password
    @State private var errorMessage = "" // Error message to display
    @State private var showError = false // Flag to show error message
    @State private var showAlert = false // Flag to show an alert
    @State private var isPasswordVisible = false // Flag to toggle password visibility
    @Binding var isSignedUp: Bool // Flag indicating if the user is signed up
    @State private var isShowingEmailVerificationAlert = false // Flag to show email verification alert
    @StateObject private var userController = UserController() // User controller object for managing users
    
    var passwordsMatch: Bool {
        return password == confirmPassword // Check if the passwords match
    }
    
    func generateUsername(email: String) -> String {
        // Generate a username based on the email
        
        guard !email.isEmpty else {
            return "CopWatchNYCDefaultUserName" // Default username if email is empty
        }
        
        var username = ""
        let emailCharacters = email.filter { $0 != "@" && $0 != "." }
        let maxIndex = emailCharacters.count - 1
        
        for _ in 0..<8 {
            let randomIndex = Int.random(in: 0...maxIndex)
            
            username += String(emailCharacters[emailCharacters.index(emailCharacters.startIndex, offsetBy: randomIndex)])
        }
        
        return username
    }
    
    private func createUser() async {
        // Create a user in the database
        
        userController.userID = Auth.auth().currentUser?.uid ?? "User Not Found"
        userController.user_name = generateUsername(email: email)
        
        do {
            try await userController.addUser()
            print("User added!: \(userController.users.last!)")
        } catch {
            print("Error: \(error)")
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color("Color 2").edgesIgnoringSafeArea(.all) // Background color
                
                VStack {
                    HStack {
                        Spacer(minLength: 0)
                        Image("Main Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 250)
                        Spacer(minLength: 0)
                    }
                    
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, -30)
                        .padding(.bottom, 10)
                    
                    HStack {
                        Image(systemName: "mail")
                        TextField("Email", text: $email) // Email text field
                        
                        Spacer()
                        
                        if(email.count != 0) {
                            Image(systemName: email.isValidEmail() ? "checkmark" : "xmark")
                                .fontWeight(.bold)
                                .foregroundColor(email.isValidEmail() ? .green : .red)
                        }
                    }
                    .padding(.top, -20)
                    .foregroundColor(.white)
                    .padding()
                    .overlay{
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 2)
                            .foregroundColor(.white)
                            .padding(.top, -20)
                    }
                    .padding()
                    
                    VStack {
                        HStack {
                            Image(systemName: "lock")
                            
                            if isPasswordVisible {
                                TextField("Password", text: $password) // Password text field
                            } else {
                                SecureField("Password", text: $password) // Secure password text field
                            }
                            
                            Spacer()
                            
                            if(password.count != 0) {
                                Image(systemName: password.isValidPassword(password) ? "checkmark" : "xmark")
                                    .fontWeight(.bold)
                                    .foregroundColor(password.isValidPassword(password) ? .green : .red)
                            }
                        }
                        .padding(.top, -20)
                        .foregroundColor(.white)
                        .padding()
                        .overlay{
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(lineWidth: 2)
                                .foregroundColor(.white)
                                .padding(.top, -20)
                        }
                        .padding()
                        
                        HStack {
                            Image(systemName: "lock")
                            
                            if isPasswordVisible {
                                TextField("Confirm Password", text: $confirmPassword) // Confirm password text field
                            } else {
                                SecureField("Confirm Password", text: $confirmPassword) // Secure confirm password text field
                            }
                            
                            Spacer()
                            
                            if confirmPassword.count != 0 {
                                Image(systemName: passwordsMatch ? "checkmark" : "xmark")
                                    .fontWeight(.bold)
                                    .foregroundColor(passwordsMatch ? .green : .red)
                            }
                            
                        }
                        .padding(.top, -20)
                        .foregroundColor(.white)
                        .padding()
                        .overlay{
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(lineWidth: 2)
                                .foregroundColor(.white)
                                .padding(.top, -20)
                        }
                        .padding()
                        
                        Text("(Password must contain 6 characters, an uppercase, and symbol)")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.currentShowingView = "login" // Navigate to the login view
                                isSignedUp = true
                            }
                        }) {
                            Text("Already have an account? ")
                                .padding()
                                .foregroundColor(.white)
                                .padding(.horizontal, 25)
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle() // Toggle password visibility
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .scaleEffect(1.5)
                                .padding(.horizontal, -10)
                                .contentShape(Rectangle())
                        }
                    }
                    
                    Spacer()
                    Spacer()
                    
                    Button {
                        if password == confirmPassword { // Check if passwords match
                            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    if (error.localizedDescription == "The email address is already in use by another account.") {
                                        errorMessage = "This email is already in use!"
                                    } else {
                                        // Create user in the database with Firebase UID
                                        return
                                    }
                                }
                                if let user = authResult?.user {
                                    user.sendEmailVerification()
                                    isShowingEmailVerificationAlert = true
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        isSignedUp = true
                                    }
                                }
                            }
                        } else {
                            showAlert = true // Display an error message
                        }
                    } label: {
                        Text("Register your Account ")
                            .foregroundColor(.black)
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(Color.white)
                            )
                            .padding(.horizontal )
                    }
                    
                    Button(action: {
                        isSignedUp = true
                        
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
                                    // Create user in the database with Firebase UID
                                    return
                                }
                                
                                isSignedUp = true
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
                            .fill(Color.black)
                    )
                    .padding(.horizontal)
                    .navigationDestination(for: String.self) { view in
                        if view == "NavBarView" {
                            Home(reportedLocations: $reportedLocations) // Navigate to the home view
                        }
                    }
                }
                
                // Display an alert if passwords do not match
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Passwords do not match"),
                        message: Text("Please make sure your passwords match."),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                // Display an alert for email verification
                .alert(isPresented: $isShowingEmailVerificationAlert) {
                    Alert(
                        title: Text("Email Verification Sent"),
                        message: Text("A verification email has been sent to your email address. Please check your inbox and follow the instructions to verify your email address."),
                        dismissButton: .default(Text("OK")) {
                            currentShowingView = "login" // Navigate to the login view
                        }
                    )
                }
            }
        }
    }
}
