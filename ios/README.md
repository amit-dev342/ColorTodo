# Head Room for iOS

This is the native SwiftUI and WidgetKit version of Head Room, matching the current Android feature set and visual direction.

Generate the Xcode project:
1. Install XcodeGen.
2. Run: cd ios
3. Run: xcodegen generate
4. Open HeadRoom.xcodeproj

The app targets iOS 17+.

App and widget data are shared through the App Group group.com.amit.headroom.

Important widget note: WidgetKit does not support a freely swipeable Android StackView-style carousel inside an iOS home-screen widget. The iOS widget keeps the same stacked-card visual treatment and exposes NEXT plus DONE / ACTIVE interactive controls. It shows the full details of one task card at a time.

The GitHub workflow builds and packages an iOS Simulator app without code signing. A signed iPhone IPA or TestFlight build requires an Apple Developer team, App Group registration, signing certificate/profile, and distribution credentials.
