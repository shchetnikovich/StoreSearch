import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {  //  Управляет анимацией перехода между вьюхами, keyframe анимация
    
    func transitionDuration(    //  Продолжительность анимации
        using transitionContext:
        UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(
        using transitionContext:
        UIViewControllerContextTransitioning
    ){
        if let toViewController = transitionContext.viewController(     //  Получаем ссылку на будущее представление объекта, чтобы понимать финал анимации
            forKey: UITransitionContextViewControllerKey.to),
           let toView = transitionContext.view(
            forKey: UITransitionContextViewKey.to) {
            let containerView = transitionContext.containerView
            toView.frame = transitionContext.finalFrame(for: toViewController)
            containerView.addSubview(toView)
            toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)   //  (1) кадр - Газуем с 70% масштаба
            
            UIView.animateKeyframes(    //  Анимируем в несколько отдельных этапов
                withDuration: transitionDuration(
                    using: transitionContext),
                delay: 0,
                options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(
                        withRelativeStartTime: 0.0,
                        relativeDuration: 0.334) {  //  Не секунлы, а доли от общего времени анимации в transitionDuration!
                            toView.transform = CGAffineTransform(   //  CGAffineTransform для масштабирования
                                scaleX: 1.2, y: 1.2)    //  (2) кадр 120%
                        }
                    UIView.addKeyframe(
                        withRelativeStartTime: 0.334,
                        relativeDuration: 0.333) {
                            toView.transform = CGAffineTransform(
                                scaleX: 0.9, y: 0.9)    //  (3) кадр 90%
                        }
                    UIView.addKeyframe(
                        withRelativeStartTime: 0.666,
                        relativeDuration: 0.333) {
                            toView.transform = CGAffineTransform(
                                scaleX: 1.0, y: 1.0)    //  (4) 100%
                        }
                }, completion: { finished in
                    transitionContext.completeTransition(finished)
                })
        }
    }
}
