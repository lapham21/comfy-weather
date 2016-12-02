//
//  BlurModalPresentationController.swift
//  ComfyWeather
//
//  Created by Son Le on 10/3/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

final class BlurModalPresentationController: UIPresentationController {

    private var blurView = UIVisualEffectView(effect: nil)

    // MARK: - Metadata for presentation

    var presentedViewWidth: CGFloat = 325.0
    var presentedViewHeight: CGFloat = 325.0

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return CGRect.zero
        }

        return CGRect(centeredIn: containerView.bounds, width: presentedViewWidth, height: presentedViewHeight)
    }

    override var shouldRemovePresentersView: Bool {
        return false
    }

    // MARK: - Presentation transition

    override func presentationTransitionWillBegin() {
        guard
            let containerView = containerView,
            let transitionCoordinator = presentingViewController.transitionCoordinator
            else { return }

        blurView.frame = containerView.bounds
        containerView.addSubview(blurView)

        transitionCoordinator.animate(
            alongsideTransition: { [weak self] _ in
                self?.blurView.effect = UIBlurEffect(style: .light)
            },
            completion: nil
        )
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            blurView.removeFromSuperview()
        }
    }

    // MARK: - Dismissal transition

    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = self.presentingViewController.transitionCoordinator else { return }
        transitionCoordinator.animate(
            alongsideTransition: { [weak self] _ in
                self?.blurView.effect = nil
            },
            completion: nil
        )
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            blurView.removeFromSuperview()
        }
    }

}
