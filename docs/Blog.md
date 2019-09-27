# Adapting Existing Apps for SwiftUI

Now that iOS 13 has been released to the public, SwiftUI and Combine are looking more and more attractive as you choose how to build your next greenfield app. But what about your existing applications? If you’re ready to drop iOS 12 and blaze new trails with SwiftUI, congratulations--and prepare yourself for an exciting journey. 

So you've shipped your app's iOS 13 updates, added dark mode, and dropped iOS 12 support... now what? 

## Beginning the Journey

As with any refactor or paradigm change, you'll want to create a plan. Translating all of your UI code into SwiftUI or rewriting your whole networking stack to use Combine probably isn't worth the effort. Instead, for each piece of new work, consider if it would be a good candidate to use with one of the new frameworks.

Luckily, these frameworks are designed to play nicely with the existing ones. For example, you can write new views in SwiftUI and nest them in your existing views, or start writing a new API client with Combine and use it as you consume new API endpoints. Your new code will benefit from the new abstractions and your old code won't need to know or care. 

As for actual project files, you won't need to mess around with your app's `Info.plist` or your Xcode project's structure unless you're planning on taking advantage of same-app multitasking in iPadOS. You can jump right in! 


## UIKit ↔️ SwiftUI
SwiftUI and UIKit views can talk to each other very easily since SwiftUI is largely an abstraction built on top of UIKit. Here's a simple example of walking the two-way street between the frameworks.

#### SwiftUI Inside UIKit

If you have a new feature that's a perfect candidate for SwiftUI, [`UIHostingController`](https://developer.apple.com/documentation/swiftui/uihostingcontroller) is going to be your BFF. `UIHostingController` is a ViewController that wraps SwiftUI views and lets you integrate them into UIKit views. 

Since it's a subclass of `UIViewController`, you can use it exactly as you're used to--subclass it for custom behavior, use it in your storyboards, or just add it as a child ViewController. 

```
import UIKit
import SwiftUI // Note the second import

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let swiftUIView: some View = SwiftUIView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        // Use this ViewController as you normally would
    }
}

```

In fact, even "pure SwiftUI" apps use a `UIHostingController` for their window's `rootViewController` property.

#### UIKit Inside SwiftUI
One of the biggest benefits of using UIKit components in SwiftUI is that your UIKit components get the same reactive capabilities as your SwiftUI components if you're using Combine.

[UIViewRepresentable](https://developer.apple.com/documentation/swiftui/uiviewrepresentable) and [UIViewControllerRepresentable](https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable) let you port existing UIKit components to SwiftUI. One of the simplest examples is `UIActivityIndicatorView`, which at the time of writing doesn't have a corresponding SwiftUI component. 

```
struct ActivityIndicatorView: UIViewRepresentable {

    @Binding var isAnimating: Bool

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView()
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
```


Your views will likely be more complicated, but you can pass data into your views easily with `makeUIView()`,  `updateUIView()`, and [`UIViewControllerRepresentable`](https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable)'s [`Coordinator`](https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable/3278027-coordinator) associated type. 

## Data Flow between UIKit and SwitUI
If you're not familiar with Swift 5's `property wrappers`, the [Data Flow Through SwiftUI](https://developer.apple.com/videos/play/wwdc2019/226) WWDC talk is a wonderful introduction. (Note that some of the property wrapper names have changed in the short time since WWDC! It is a bleeding-edge framework after all 😁)

You may have noticed that the `ActivityIndicatorView` reads the `@Binding` in the example above. Writing to an `@Binding` variable from UIKit is as simple as giving your `UIView` or `UIViewController` a `Coordinator`. 


Here we construct a simple view that will greet the user if `isGreeting` is `true`. It provides a button for the user to toggle the state of `isGreeting`. 


<!--
Note to editor: 
I have screenshots of the views, but I'm not sure it will look amazing in the context of the article. If we want to crop or style these views/images differently, I'm happy to do that!
-->

```
import SwiftUI

struct GreetingView: View {
   @State private var isGreeting: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                if isGreeting {
                    Text("Hello")
                }
                
                Text("World!")
            }
            
            GreetingButton(isGreeting: $isGreeting)
        }
    }
}
```
<br />

Next we have the `GreetingButton`, a `UIViewRepresentable` that wraps a `UIButton`. Pressing this button shows or hides the greeting.

```
struct GreetingButton: UIViewRepresentable {
    @Binding var isGreeting: Bool
    
    private var buttonText: String {
        "\(isGreeting ? "Disable" : "Enable") greeting"
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<GreetingButton>) -> UIButton {
        let button = UIButton()
        button.setTitle(buttonText, for: .normal)
        button.addTarget(context.coordinator, action: #selector(context.coordinator.greetingButtonPressed(_:)), for: .touchUpInside)
        
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: UIViewRepresentableContext<GreetingButton>) {
        uiView.setTitle(buttonText, for: .normal)
    }
}
```
<br />

Finally, we have a `Coordinator` that handles the `UIButton`'s target-action events and modifies the bound `isGreeting` value. This `Coordinator` can be its own class or it can be nested inside the `GreetingButton` struct 

```
/// Use a Coordinator for target-action, protocol adoption (perfect for delegates and data sources!), and to pass data in and out of your UIView.
class Coordinator: NSObject {
    var parent: GreetingButton
    
    init(_ parent: GreetingButton) {
        self.parent = parent
    }
    
    @objc func greetingButtonPressed(_ sender: UIButton) {
        parent.isGreeting.toggle()
    }
}
```

Consider what this implementation would look like pre-SwiftUI. Your button's tap handler would need to edit the state, update the button's UI, and then update the greeting labels. Add a ViewController and you'd need to manage multiple sources of truth. This example may be trivial, but it is a great demonstration of how SwiftUI allows for single source of truth (`isGreeting`).

Now your `GreetingButton`'s tap handler just toggles a piece of state and each UI element is re-rendered by SwiftUI. A good piece of boilerplate is removed, your views are simpler, and they can react to state changes automatically by doing a lot of the hard work for you. 

## Next Steps
These examples only scratch the surface of SwiftUI. While you are likely to find yourself reaching for the new frameworks more frequently as the platform matures, don't forget the power of SwiftUI and UIKit's interoperability if you find yourself scratching your head. SwiftUI is still young and it will certainly evolve as its paradigms are refined. With some foresight and ambition, you can even influene the direction the community takes the platform.

Welcome to SwiftUI! 
