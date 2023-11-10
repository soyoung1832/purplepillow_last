import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button(action: {
                UnityFramework.shared.launchUnity()
                
            }) {
                Text("Launch Unity!")
            }
        }
    }
}
