import SwiftUI
import FirebaseAuth

// The View for Creating Reports
struct CreateReportView: View {
    @State private var selectedIndex: Int = 0 // Index for the first carousel view
    @State private var secondCarouselIndex: Int = 0 // Index for the second carousel view
    @StateObject private var addressViewModel = AddressViewModel() // View model for handling the address text field
    @StateObject private var pinningController = PinningController() // Controller for managing pinning functionality
    @Environment(\.presentationMode) var presentationMode // Environment variable for dismissing the view
    @EnvironmentObject var locationManager: LocationManager // Environment object for managing location updates
    @Binding var reportedLocations: [IdentifiablePin] // Binding to the reported locations array
    @Binding var selectedTab: String // Binding to the selected tab in the app

    let globalUserID = Auth.auth().currentUser?.uid // Current user's ID
    
    // Arrays of the images for the two carousel views
    let firstCarouselImages = ["subway", "public", "bus"]
    let secondCarouselImages = ["fare", "heavy", "other"]
    
    private func storeReportLocation() async {
        guard let userLocation = locationManager.location else { return } // Get user's location
        let reportLocation = userLocation.coordinate // Extract the coordinate
        let (firstOptionText, secondOptionText) = selectedOptionText() // Get the selected options from the carousels
        reportedLocations.append(IdentifiablePin(location: reportLocation, firstCarouselOption: firstOptionText, secondCarouselOption: secondOptionText)) // Add the report location to the array
        
        print("New report added: \(reportedLocations.last!)")
        
        pinningController.latitude = reportLocation.latitude
        pinningController.longitude = reportLocation.longitude
        pinningController.report = firstOptionText
        pinningController.report_detail = secondOptionText
        pinningController.report_location = addressViewModel.address
        //pinningController.userID = globalUserID ?? "User Not Logged In"
        pinningController.userID = Constants.testUserIDHosted
        
        do {
            try await pinningController.addPin() // Add the pin using the pinning controller
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    // Function for changing the text based on selection
    func selectedOptionText() -> (String, String) {
        let firstOptionText = selectedIndex == 0 ? "Cops in Subway Station" : (selectedIndex == 1 ? "Cops in Public" : "Cops near Bus Stop")
        let secondOptionText = secondCarouselIndex == 0 ? "Checking for Fare Evaders" : (secondCarouselIndex == 1 ? "Heavy Presence" : "Add what is happening in the comments of your post!")
        
        return (firstOptionText, secondOptionText)
    }
    
    var body: some View {
        // Changing the gradient background color with a ZStack
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(.black), Color("Color 1")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Text that shows the questions for the carousel views
                Text("What Would You Like to Report?")
                    .font(.title)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundColor(.white)
                
                // Text showing the selected option for the first carousel view
                Text(selectedIndex == 0 ? "Cops in Subway Station" : (selectedIndex == 1 ? "Cops in Public" : "Cops near Bus Stop"))
                    .font(.headline)
                    .foregroundColor(.white)
                
                // First carousel for selecting which report
                CarouselView(selectedIndex: $selectedIndex, images: firstCarouselImages)
                
                // Text for report details and the second carousel
                Text("What's Happening?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Text showing the options for the second carousel
                Text(secondCarouselIndex == 0 ? "Checking for Fare Evaders" : (secondCarouselIndex == 1 ? "Heavy Presence" : "Add what is happening in the comments of your post!"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Second carousel for selecting details of the report
                CarouselView(selectedIndex: $secondCarouselIndex, images: secondCarouselImages)
                
                // The text field to enter the general description of the area
                Text("State a general description of the area.")
                    .font(.title)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                TextField("Ex: Corner of 23rd st; In subway station; etc..", text: $addressViewModel.address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundColor(.black)
                
                // The button to post the report
                PostButtonView(action: {
                    if let _ = Auth.auth().currentUser {
                        // User is logged in, store the report
                        Task {
                            await storeReportLocation()
                            presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        // User is not logged in, show the login alert

                    }
                }, selectedTab: $selectedTab)
                .padding(.top, 20)
            }
        }
    }
}

struct CarouselView: View {
    // The binding variable for the selected index and array of images for the carousels
    @Binding var selectedIndex: Int
    let images: [String]
    
    var body: some View {
        // Tabview with a foreach loop over the images array
        TabView(selection: $selectedIndex) {
            ForEach(0..<images.count, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .cornerRadius(20)
                    .padding()
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

class AddressViewModel: ObservableObject {
    @Published var address: String = ""
}

struct PostButtonView: View {
    let action: @MainActor () async -> Void
    @Binding var selectedTab: String
    
    var body: some View {
        Button(action: {
            Task {
                await action()
                selectedTab = "home"
            }
        }) {
            // Frontend of Post button
            Text("Post Your Report!")
                .font(.headline)
                .fontWeight(.bold)
                .padding()
                .background(Color("Color"))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

// Live Preview for the Create Report View
struct CreateReportView_Previews: PreviewProvider {
    @State static private var previewReportedLocations: [IdentifiablePin] = []
    @State static private var selectedTab = "report"
    
    static var previews: some View {
        CreateReportView(reportedLocations: $previewReportedLocations, selectedTab: $selectedTab)
    }
}
