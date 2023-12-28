import UIKit

class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private let favoritesKey = "favorites"

    private init() {}

    func saveImageToFavorites(_ image: UIImage) {
        guard let data = image.pngData() else { return }

        var favoritePaths = getFavoritePaths()
        let fileName = UUID().uuidString + ".png"
        let filePath = FileManager.documentsDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: filePath)
            favoritePaths.append(filePath.path)
            saveFavoritePaths(favoritePaths)
        } catch {
            print("Error saving image to file: \(error.localizedDescription)")
        }
    }

 
    func isImageInFavorites(_ image: UIImage?) -> Bool {
        guard let image = image else {
            return false
        }

        let favoritePaths = getFavoritePaths()
        let imageData = image.pngData()

        return favoritePaths.contains { path in
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  let pathImage = UIImage(data: data)
            else {
                return false
            }
            return pathImage.pngData() == imageData
        }
    }
    func getImagePath(for image: UIImage) -> String? {
        guard let data = image.pngData() else {
            return nil
        }

        let fileName = UUID().uuidString + ".png"
        let filePath = FileManager.documentsDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: filePath)
            return filePath.path
        } catch {
            print("Error saving image to file: \(error.localizedDescription)")
            return nil
        }
    }

    func removeImageFromFavorites(_ image: UIImage) {
          let imageData = image.pngData()

          var favoritePaths = getFavoritePaths()
          if let index = favoritePaths.firstIndex(where: { path in
              guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                    let pathImage = UIImage(data: data)
              else {
                  return false
              }
              return pathImage.pngData() == imageData
          }) {
              do {
                  try FileManager.default.removeItem(atPath: favoritePaths[index])
                  favoritePaths.remove(at: index)
                  saveFavoritePaths(favoritePaths)
              } catch {
                  print("Error removing image from file: \(error.localizedDescription)")
              }
          }
      }
    func getFavoriteImages() -> [UIImage] {
        let favoritePaths = getFavoritePaths()
        var images: [UIImage] = []
        for path in favoritePaths {
            if let image = UIImage(contentsOfFile: path) {
                images.append(image)
            }
        }
        return images
    }

    // Change access level to internal
    internal func getFavoritePaths() -> [String] {
        if let paths = UserDefaults.standard.stringArray(forKey: favoritesKey) {
            return paths
        }
        return []
    }

    // Change access level to internal
    internal func saveFavoritePaths(_ paths: [String]) {
        UserDefaults.standard.set(paths, forKey: favoritesKey)
        UserDefaults.standard.synchronize()
    }
}
extension FileManager {
    static var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
