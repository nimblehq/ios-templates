import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let homeViewController = HomeViewController()
        let _navController = UINavigationController(rootViewController: homeViewController)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = _navController
        window?.makeKeyAndVisible()


        

        let optional: String? = "Hello world!"
        let nonOptional = optional as! String
        return true
    }
}
