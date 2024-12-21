@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

            window = UIWindow(windowScene: windowScene)
            let controller = FlutterViewController.init(engine: flutterEngine, nibName: nil, bundle: nil)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
              appDelegate.window = window
          }
            window?.rootViewController = controller
            window?.makeKeyAndVisible()
    }
}
