import SwiftUI

// Custom Tab Bar View
struct CustomTabBar: View {
    @Binding var selectedTab: String
    
    @Namespace var animation
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(animation: animation, image: "home", selectedTab: $selectedTab)
            
            // Button for the report tab
            Button(action: {
                selectedTab = "report"
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(Color("Color 2"))
                    .padding()
                    .frame(width: 70, height: 70)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.25), radius: 5, x: 5, y: 5)
                    .shadow(color: Color.black.opacity(0.25), radius: 5, x: -5, y: -5)
            }
            .offset(y: -45)
            
            TabBarButton(animation: animation, image: "user", selectedTab: $selectedTab)
        }
        .padding(.vertical, 10)
        .padding(.bottom, -35)
        .background(Color("Color"))
    }
}

// Preview Provider for Custom Tab Bar
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Tab Bar Button View
struct TabBarButton: View {
    var animation: Namespace.ID
    var image: String
    @Binding var selectedTab: String
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = image
            }
        }) {
            VStack(spacing: 6) {
                // Tab bar button icon
                Image(image)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(selectedTab == image ? Color.white : Color.gray.opacity(0.6))
                
                if selectedTab == image {
                    // Animation for selected tab
                    Circle()
                        .fill(Color.white)
                        .matchedGeometryEffect(id: "TAB", in: animation)
                        .frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
