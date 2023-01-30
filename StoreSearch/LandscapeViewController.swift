import UIKit

class LandscapeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var searchResults = [SearchResult]()
    
    private var firstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.removeConstraints(view.constraints)    // Отключаем Auto Layout Remove constraints from main view
        view.translatesAutoresizingMaskIntoConstraints = true   //  Позиционируем и изменяем размеры наших вьюх вручную (удаляем автоматические ограничения AutoresizingMask)
        
        pageControl.removeConstraints(pageControl.constraints)   // Remove constraints for page control
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)    // Remove constraints for scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        pageControl.numberOfPages = 0
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
        
        if firstTime {
            firstTime = false
            tileButtons(searchResults)
        }
    }
    
    // MARK: - Private Methods
    
    private func tileButtons(_ searchResults: [SearchResult]) {     //  Вручную указывам размер будущих Grid Tile'ов
        
        let itemWidth: CGFloat = 94     //  Выйдет grid 4 row, 7 column (iPhone SE)
        let itemHeight: CGFloat = 88
        var columnsPerPage = 0
        var rowsPerPage = 0
        var marginX: CGFloat = 0
        var marginY: CGFloat = 0
        let viewWidth = scrollView.bounds.size.width
        let viewHeight = scrollView.bounds.size.height
        
        columnsPerPage = Int(viewWidth / itemWidth)         //  Вычисляем кол-во tail'ов
        rowsPerPage = Int(viewHeight / itemHeight)
        
        marginX = (viewWidth - (CGFloat(columnsPerPage) * itemWidth)) * 0.5     //  Вычисляем отступы по х и у
        marginY = (viewHeight - (CGFloat(rowsPerPage) * itemHeight)) * 0.5
        
        //  Размеры будущих кнопок
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeight) / 2
        
        //  Рисуем кнопки
        var row = 0
        var column = 0
        var x = marginX
        for (index, result) in searchResults.enumerated() {
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor.white
            button.setTitle("\(index)", for: .normal)

            button.frame = CGRect(  //  Обязательно необходимо установить .frame
                x: x + paddingHorz,
                y: marginY + CGFloat(row) * itemHeight + paddingVert,
                width: buttonWidth,
                height: buttonHeight)
            
            scrollView.addSubview(button)

            row += 1
            if row == rowsPerPage {
                row = 0; x += itemWidth; column += 1
                if column == columnsPerPage {
                    column = 0; x += marginX * 2
                }
            }
        }
        
        // Устанавливаем представление для scrollview.contentSize
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(
            width: CGFloat(numPages) * viewWidth,
            height: scrollView.bounds.size.height)
        print("Number of pages: \(numPages)")
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
    
    // MARK: - Actions
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                self.scrollView.contentOffset = CGPoint(
                    x: self.scrollView.bounds.size.width *
                    CGFloat(sender.currentPage),
                    y: 0)
            }
        )
    }
}

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControl.currentPage = page
    }
}
