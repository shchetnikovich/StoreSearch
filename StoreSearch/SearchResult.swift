import Foundation

class ResultArray: Codable {        //  Add a new data model for the results wrappe
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult: Codable, CustomStringConvertible {        //      Создаём новый класс для хранения данных, CustomStringConvertible protocol allows an object to have a custom string representation
    
    var trackName: String? = ""
    var artistName: String? = ""
    
    var kind: String? = ""
    
    var trackPrice: Double? = 0.0
    var currency = ""
    var collectionPrice: Double?
    var itemPrice: Double?
    
    var imageSmall = ""
    var imageLarge = ""
    
    var trackViewUrl: String?
    var collectionViewUrl: String?
    
    var collectionName: String?
    
    var itemGenre: String?
    var bookGenre: [String]?
    
    
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, currency
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionViewUrl, collectionPrice
    }
    
    //MARK: - Computed Properties
    
    var description: String {   //  description p to conform to the CustomStringConvertible
        return "\nРезультат - Тип: \(kind ?? "Неизвестно") Песня: \(name), Исполнитель: \(artistName ?? "Неизвестно")"
    }
    
    var name: String {      //  Вычисляемое свойство, возвращает trackName или пустую строку, если сабж is nil (когда будем парсить придет пустой ответ с сервера)
        return trackName ?? collectionName ?? ""
    }
    
    var artist: String {
        return artistName ?? ""
    }
    
    var storeURL: String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }
    
    var price: Double {
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }
    
    var genre: String {
        if let genre = itemGenre {
            return genre
        } else if let genres = bookGenre {
            return genres.joined(separator: ", ")
        }
        return ""
    }
    
    var type: String {
      let kind = self.kind ?? "audiobook"
      switch kind {
      case "album": return "Альбом"
      case "audiobook": return "Аудио Книга"
      case "book": return "Книга"
      case "ebook": return "Электронная книга"
      case "feature-movie": return "Кино"
      case "music-video": return "Музыкальный клип"
      case "podcast": return "Подскаст"
      case "software": return "Приложение"
      case "song": return "Песня"
      case "tv-episode": return "Серия"
      default: break
      }
      return "Неизвестно"
    }
}

//MARK: - Helper Methods

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name)
    == .orderedAscending
}
