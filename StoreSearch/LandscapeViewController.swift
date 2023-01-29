import UIKit

class LandscapeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.removeConstraints(view.constraints)    // Отключаем Auto Layout Remove constraints from main view
        view.translatesAutoresizingMaskIntoConstraints = true   //  Позиционируем и изменяем размеры наших вьюх вручную (удаляем автоматические ограничения AutoresizingMask)
    
        pageControl.removeConstraints(pageControl.constraints)   // Remove constraints for page control
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)    // Remove constraints for scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
    }
}
