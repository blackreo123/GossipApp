import SwiftUI

struct ContentView: View {
    @AppStorage("hasAgreedToPrivacyPolicy") private var hasAgreedToPrivacyPolicy = false
    
    var body: some View {
        Group {
            if hasAgreedToPrivacyPolicy {
                GossipView()
            } else {
                PrivacyPolicyOnboardingView(hasAgreed: $hasAgreedToPrivacyPolicy)
            }
        }
    }
}
