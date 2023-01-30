import UIKit

class LandscapeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var search: Search!
    
    private var firstTime = true
    
    private var downloads = [URLSessionDownloadTask]()
    
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
            switch search.state {
            case .notSearchedYet, .loading:
                break
            case .noResults:
                showNothingFoundLabel()
            case .results(let list):
                tileButtons(list)
            }
        }
    }
    
    deinit {
        print("deinit \(self)")
        for task in downloads {
            task.cancel()
        }
    }
    
    // MARK: - Helper Methods
    
    func searchResultsReceived() {
        hideSpinner()
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            break
        case .results(let list):
            tileButtons(list)
        }
    }
    
    // MARK: - Private Methods
    
    private func tileButtons(_ searchResults: [SearchResult]) {     //  Указывам размер будущих Grid Tile'ов
        
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
        for (_, result) in searchResults.enumerated() {
            
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            downloadImage(for: result, andPlaceOn: button)
            
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
    
    private func downloadImage(
        
        for searchResult: SearchResult,
        andPlaceOn button: UIButton
    ){
        if let url = URL(string: searchResult.imageSmall) {
            let task = URLSession.shared.downloadTask(with: url) {
                [weak button] url, _, error in
                if error == nil, let url = url,
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {        //!!!
                    DispatchQueue.main.async {
                        if let button = button {
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            task.resume()
            downloads.append(task)
        }
    }
    
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = CGPoint(       //  Центр экрана
            x: scrollView.bounds.midX + 0.5,
            y: scrollView.bounds.midY + 0.5) // При добавлении в центр, спинер будет размыт т.к. нечетная ширина сабжа 37 поинтс
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    private func hideSpinner() {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    private func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Ничего не найдено"
        label.textColor = UIColor.label
        label.backgroundColor = UIColor.clear   //  0% opacity
        label.sizeToFit()
        var rect = label.frame
        
        rect.size.width = ceil(rect.size.width / 2) * 2     //  Ceil - округляет число в большую сторону, тут всегда будет четное число
        rect.size.height = ceil(rect.size.height / 2) * 2
        
        label.frame = rect
        label.center = CGPoint(
            x: scrollView.bounds.midX,
            y: scrollView.bounds.midY)
        view.addSubview(label)
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

//MARK: - Extension

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControl.currentPage = page
    }
}
