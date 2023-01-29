

import UIKit

class DetailViewController: UIViewController {
    
    enum AnimationStyle {       //  Стили анимации закрытия вьюхи
        case slide  //  Убегает навверх
        case fade   //  Затухает
    }
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var searchResult: SearchResult!
    
    var downloadTask: URLSessionDownloadTask?   //  Важно для cancel downloadTask!
    
    var dismissStyle = AnimationStyle.fade  //  По умолчанию стиль скрытия
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.layer.cornerRadius = 10
        
        let gestureRecognizer = UITapGestureRecognizer(     //  Слушаем вьюху, если тап мимо - close() кидаем
            target: self,
            action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        if let _ = searchResult {updateUI()}    //  Проверка!
        
        view.backgroundColor = UIColor.clear    //  Пошёл градиент
        let dimmingView = GradientView(frame: CGRect.zero)
        dimmingView.frame = view.bounds
        view.insertSubview(dimmingView, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {   //  Делегат для перехода, когда требуется контроллер анимации
        super.init(coder: aDecoder)
        transitioningDelegate = self
    }
    
    deinit {
      print("deinit \(self)")
      downloadTask?.cancel()    //  Отменяем загрузку данных, если закрыли поп-ап вьюху до финиша загрузки
    }
    
    // MARK: - Helper Methods
    
    func updateUI() {
        nameLabel.text = searchResult.name
        
        if let largeURL = URL(string: searchResult.imageLarge) {        //  Получаем изображение
          downloadTask = artworkImageView.loadImage(url: largeURL)
        }
        
        if searchResult.artist.isEmpty {
            artistNameLabel.text = "Неизвестно"
        } else {
            artistNameLabel.text = searchResult.artist
        }
        kindLabel.text = searchResult.type
        genreLabel.text = searchResult.genre
        
        let formatter = NumberFormatter()       //  Фиксируем цену $$$ создаём formatter
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        
        let priceText: String
        
        if searchResult.price == 0 {
            priceText = "Бесплатно"
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {       //  Пытаем отобразить в достойном виде
            priceText = text
        } else {
            priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func close() {
        dismissStyle = .slide   //  При тапе на крестик внутри поп-апа
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore() {      //  Газуем в iTunes по storeURL
        if let url = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}


//MARK: - UIGestureRecognizerDelegate Extension

extension DetailViewController: UIGestureRecognizerDelegate {       //  Фиксируем тап вне pop-up вьюхи
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        return (touch.view === self.view)
    }
}

//MARK: - Animation Extension

extension DetailViewController: UIViewControllerTransitioningDelegate {     //  Делаем кастомную анимацию
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()  //  show pop-up
    }
    
    func animationController(
      forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {   //  Тут свичер на анимацию закрытия поп-апа (в завис. от альбом/портрет)
          case .slide:
            return SlideOutAnimationController()
          case .fade:
            return FadeOutAnimationController()
          }
    }
    
}
