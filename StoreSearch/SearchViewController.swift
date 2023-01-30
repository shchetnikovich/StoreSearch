import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private let search = Search()
    
    var landscapeVC: LandscapeViewController?
    
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0) // 100 исходя из высоты SearchBar'a 56 + 44 Segment Control
        
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)   //  Регистрируем .nib файлы
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        searchBar.becomeFirstResponder()    //  Show keyboard on app launch
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
    }
    
    override func willTransition(   //  Меняем вьюху portrait/landscape (reg
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator
    ){
        super.willTransition(to: newCollection, with: coordinator)
        switch newCollection.verticalSizeClass {    //  Триггеримся от trait collection verticalSizeClass, свичим вьюху
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:    //  .unspecified доп защита в данной ситуации
            hideLandscape(with: coordinator)
        @unknown default:
            break
        }
    }
    
    
    // MARK: - Navigation
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
            }
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
}

// MARK: - Search Bar Delegate

extension SearchViewController: UISearchBarDelegate {
    
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearch(
                for: searchBar.text!,
                category: category
            ){
                success in
                if !success  { self.showNetworkError() }
                self.tableView.reloadData()
            }
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {    //   Прижимаем SearchBar к StatusBar Area
        return .topAttached
    }
}

// MARK: - Table View Delegate

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        switch search.state {
        case .notSearchedYet:
            fatalError("Ошибка")
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    //MARK: - Selection Handling
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)    //  Отменяет выделение с анимацией
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)   //  Переходим в Detail Scene
    }
    
    func tableView(     //  Гарантирует возможность выбора строки, при наличии результатов поиска.
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            return nil
        case .results:
            return indexPath
        }
    }
    
    // MARK: - Helper Methods
    
    func showNetworkError() {       //  Error handling
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Неудалось получить доступ к сервисам iTunes Store." +
            " Попробуйте позже.",
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else { return }    //  Защита от дублирования вьюхи
        landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController //   Вручную прописываем landscapeVC (сиги неу)
        if let controller = landscapeVC {   //  Анврапаем
            controller.search = search
            controller.view.frame = view.bounds //  Описываем размер альбомной вьюхи от родительской супервью
            controller.view.alpha = 0
            view.addSubview(controller.view)    //  Помещаем новую вьюху поверх старой SearchView
            addChild(controller)    //  Обязательно сообщаем о "Детях"
            
            coordinator.animate(alongsideTransition: { _ in     //  Кроссфейд анимация перехода между портрет/альбом
                controller.view.alpha = 1   //  Меняем альфу на 1 (100% opacity)
                self.searchBar.resignFirstResponder()   //  Скрываем keyboard
                
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)   //  Скрываем поп-ап вьюху в в альбомной ориентации
                }
            }, completion: { _ in
                controller.didMove(toParent: self)
            }
            )
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            coordinator.animate(        //  Анимация fade out, также удаляем вьюху и контроллер
                alongsideTransition: { _ in
                    controller.view.alpha = 0
                }, completion: { _ in
                    controller.view.removeFromSuperview()
                    controller.removeFromParent()
                    self.landscapeVC = nil
                }
            )
        }
    }
}
