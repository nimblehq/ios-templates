//
//  Navigator.swift
//

import UIKit

// sourcery: AutoMockable
protocol Navigatable: AnyObject {

    func show(scene: Navigator.Scene, sender: UIViewController?, transition: Navigator.Transition)
    func dismiss(sender: UIViewController?)
    func pop(sender: UIViewController?)
    func popToRoot(sender: UIViewController?)
}

final class Navigator {

    private func viewController(from scene: Scene) -> UIViewController {
        switch scene {
        case .home:
            return HomeViewController()
        }
    }
}

extension Navigator: Navigatable {

    func show(scene: Scene, sender: UIViewController?, transition: Transition) {
        let target = viewController(from: scene)
        if case let .root(window) = transition {
            let snapshotOverlayView = UIScreen.main.snapshotView(afterScreenUpdates: false)
            target.view.addSubview(snapshotOverlayView)
            window?.rootViewController = target
            window?.makeKeyAndVisible()
            UIView.animate(
                withDuration: 0.4,
                delay: 0.0,
                options: .transitionCrossDissolve,
                animations: {
                    snapshotOverlayView.alpha = 0.0
                },
                completion: { _ in
                    snapshotOverlayView.removeFromSuperview()
                }
            )
            return
        }
        guard let sender = sender else {
            fatalError("Need sender for navigation or modal transition")
        }

        switch transition {
        case .navigation:
            sender.navigationController?.pushViewController(target, animated: true)
        case .modal:
            let navigationController = UINavigationController(rootViewController: target)
            sender.present(navigationController, animated: true, completion: nil)
        case .alert:
            sender.present(target, animated: true, completion: nil)
        case .root:
            fatalError("Never fired this case")
        }
    }

    func dismiss(sender: UIViewController?) {
        sender?.navigationController?.dismiss(animated: true, completion: nil)
    }

    func pop(sender: UIViewController?) {
        sender?.navigationController?.popViewController(animated: true)
    }

    func popToRoot(sender: UIViewController?) {
        sender?.navigationController?.popToRootViewController(animated: true)
    }
}
