import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button(action: {
                Unity.shared.launchUnity()
                
            }) {
                Text("Launch Unity!")
            }
        }
    }
}
