import UIKit

class LandscapeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var searchResults = [SearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.removeConstraints(view.constraints)    // Отключаем Auto Layout Remove constraints from main view
        view.translatesAutoresizingMaskIntoConstraints = true   //  Позиционируем и изменяем размеры наших вьюх вручную (удаляем автоматические ограничения AutoresizingMask)
    
        pageControl.removeConstraints(pageControl.constraints)   // Remove constraints for page control
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)    // Remove constraints for scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
//        scrollView.contentSize = CGSize(width: 1000, height: 1000)
    }
    
    override func viewWillLayoutSubviews() {        //  Впервые появляемся на экране, вручную описываем новый layout LandscapeView
        super.viewWillLayoutSubviews()
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame = safeFrame
        pageControl.frame = CGRect(
            x: safeFrame.origin.x,
            y: safeFrame.size.height - pageControl.frame.size.height,
            width: safeFrame.size.width,
            height: pageControl.frame.size.height)
    }
    
    
}
