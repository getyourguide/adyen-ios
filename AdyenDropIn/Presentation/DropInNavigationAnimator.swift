//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class DropInNavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private enum Animation: String {
        case dropinTransitionPresentation = "transition_presentation"
    }
    
    private var isPush: Bool
    
    private let duration: TimeInterval
    
    private weak var dropInNavigationLayouter: DropInNavigationLayouter?
    
    internal init(duration: TimeInterval, isPush: Bool,
                  dropInNavigationLayouter: DropInNavigationLayouter?) {
        self.duration = duration
        self.isPush = isPush
        self.dropInNavigationLayouter = dropInNavigationLayouter
    }
    
    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toShow = transitionContext.viewController(forKey: .to),
              let toHide = transitionContext.viewController(forKey: .from) else { return }

        let containerView = transitionContext.containerView
        containerView.addSubview(toShow.view)
        toShow.view.frame.origin.x = isPush ? containerView.bounds.width : -containerView.bounds.width
        
        toShow.view.layoutIfNeeded()
        
        let toShowHeight = toShow.preferredContentSize.height
        let toHideHeight = toHide.preferredContentSize.height
        
        if toHideHeight >= toShowHeight {
            dropInNavigationLayouter?.updateTopViewControllerIfNeeded(animated: true)
        }
        dropInNavigationLayouter?.freezeFrameUpdate()
        
        let context = SpringAnimationContext(
            animationKey: Animation.dropinTransitionPresentation.rawValue,
            duration: duration,
            delay: 0.3,
            dampingRatio: 0.8,
            velocity: 0.2,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: { [weak self] in
                if self?.isPush ?? false {
                    toHide.view.frame.origin.x = -toHide.view.frame.width
                } else {
                    toHide.view.frame.origin.x = toHide.view.frame.width
                }
                toShow.view.frame.origin.x = containerView.frame.origin.x
            }, completion: { [weak dropInNavigationLayouter] finished in
                transitionContext.completeTransition(finished)
                
                dropInNavigationLayouter?.unfreezeFrameUpdate()
                
                if toShowHeight > toHideHeight {
                    dropInNavigationLayouter?.updateTopViewControllerIfNeeded(animated: true)
                }
            }
        )
        
        containerView.adyen.animate(context: context)
    }
}