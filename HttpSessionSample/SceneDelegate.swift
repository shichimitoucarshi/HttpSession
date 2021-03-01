//
//  SceneDelegate.swift
//  HttpSessionSample
//
//  Created by keisuke yamagishi on 2020/12/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let sceneWindow = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: sceneWindow)
        let storyboard = UIStoryboard(name: "View", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? ViewController else { return }
        let navigationController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
