import UIKit

class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {    //  Анимация закрытия
    
    func transitionDuration(
        using transitionContext:
        UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return 0.3  // секунды
    }
    
    func animateTransition(
        using transitionContext:
        UIViewControllerContextTransitioning
    ){
        if let fromView = transitionContext.view(
            forKey: UITransitionContextViewKey.from) {      // Направление анимации из вьюхи в новый контейнер
            let containerView = transitionContext.containerView
            let time = transitionDuration(using: transitionContext)
            
            UIView.animate(
                withDuration: time,
                animations: {
                    fromView.center.y -= containerView.bounds.size.height //    Вычитаем высоту экрана из центрольного положения вьюхи и уменьшаем её до 50%
                    fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }, completion: { finished in
                    transitionContext.completeTransition(finished)
                }
            )
        }
    }
}
