import ProjectDescription

let project = Project(
    name: "GossipApp",
    targets: [
        .target(
            name: "GossipApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.gossipapp.ios",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "임귀당귀",  // 디바이스 표시명
                    "CFBundleName": "임귀당귀",        // 앱 이름
                    "CFBundleShortVersionString": "1.0",
                    "CFBundleVersion": "1",
                    "UILaunchStoryboardName": "LaunchScreen",
                    "ITSAppUsesNonExemptEncryption": false,  // 암호화 미사용 선언 (수출 규정 면제)
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ]
                ]
            ),
            sources: ["GossipApp/Sources/**"],
            resources: ["GossipApp/Resources/**"],
            dependencies: [
                .external(name: "SocketIO"),
//                .target(name: "GossipCore")
            ]
        ),
//        .target(
//            name: "GossipCore",
//            destinations: .iOS,
//            product: .framework,
//            bundleId: "com.gossipapp.core",
//            deploymentTargets: .iOS("17.0"),
//            sources: ["GossipCore/Sources/**"]
//        ),
        .target(
            name: "GossipAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.gossipapp.tests",
            infoPlist: .default,
            sources: ["GossipApp/Tests/**"],
            dependencies: [
                .target(name: "GossipApp"),
//                .target(name: "GossipCore")
            ]
        )
    ]
)
