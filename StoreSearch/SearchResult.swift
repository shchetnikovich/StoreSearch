import Foundation

class ResultArray: Codable {        //  Add a new data model for the results wrappe
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult: Codable, CustomStringConvertible {        //      Создаём новый класс для хранения данных, CustomStringConvertible protocol allows an object to have a custom string representation
    
    var trackName: String? = ""
    var artistName: String? = ""
    
    var name: String {      //  Вычисляемое свойство, возвращает trackName или пустую строку, если сабж is nil (когда будем парсить придет пустой ответ с сервера)
        return trackName ?? ""
    }
    
    var description: String {   //  description p to conform to the CustomStringConvertible
      return "\nРезультат - Песня: \(name), Исполнитель: \(artistName ?? "Неизвестно")"
        
    }
    
}
