import SwiftUI

// Home View
struct Home: View {
    @State var selectedTab: String = "home" // Keeps track of the selected tab
    @Binding var reportedLocations: [IdentifiablePin] // Binding to the reported locations array
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                // Home tab with MapView
                MapView(reportedLocations: $reportedLocations)
                    .tag("home")
                
                // User account tab
                AccountView()
                    .tag("user")
                
                // Report creation tab
                CreateReportView(reportedLocations: $reportedLocations, selectedTab: $selectedTab)
                    .tag("report")
            }
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .background(Color("Color 2")) // Background color
    }
}

// Preview Provider for Home View
//struct Home_Previews: PreviewProvider {
//    static var previews: some View {
//        Home()
//    }
//}
