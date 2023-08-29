import SwiftUI

struct ContentView: View {
    var body: some View {
        Button(action: {
            Unity.shared.show()
        }) {
            Text("Launch Unity!")
        }
    }
}
