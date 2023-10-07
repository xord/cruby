import SwiftUI

@main
struct CRubyApp: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text(CRuby.evaluate(":hello").toString())
            }
            .padding()
        }
    }
}
