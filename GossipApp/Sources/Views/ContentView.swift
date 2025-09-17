import SwiftUI

struct ContentView: View {
    @AppStorage("hasAgreedToTerms") private var hasAgreedToTerms = false
    @AppStorage("hasAgreedToPrivacyPolicy") private var hasAgreedToPrivacyPolicy = false
    
    var body: some View {
        Group {
            if !hasAgreedToTerms {
                TermsConditionsView(hasAgreedToTerms: $hasAgreedToTerms)
            } else if !hasAgreedToPrivacyPolicy {
                PrivacyPolicyOnboardingView(hasAgreed: $hasAgreedToPrivacyPolicy)
            } else {
                GossipView()
            }
        }
    }
}
