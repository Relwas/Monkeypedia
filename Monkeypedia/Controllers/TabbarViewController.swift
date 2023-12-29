
import UIKit

@available(iOS 13.0, *)
class TabbarViewController: UITabBarController, UITabBarControllerDelegate {
 
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.isTranslucent = false

        self.delegate = self
        configureAppearance()
        setupTabs()
        view.backgroundColor = UIColor(named: "fon ")
        tabBar.backgroundColor = UIColor(named: "fon")
        self.tabBar.tintColor = .systemYellow
        self.tabBar.unselectedItemTintColor = .gray

        let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "TeluguSangamMN-Bold", size: 20.0) ?? UIFont.systemFont(ofSize: 18.0),
                    .foregroundColor: UIColor(named: "labelColor1") ?? UIColor.black
                ]
        
                if let viewControllers = viewControllers {
                    for viewController in viewControllers {
                        if let navController = viewController as? UINavigationController {
                            navController.navigationBar.titleTextAttributes = attributes
                        }
                    }
                }
            }
    
    private func configureAppearance() {
        UINavigationBar.appearance().tintColor = .gray
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
         if let index = tabBarController.viewControllers?.firstIndex(of: viewController),
             let tabBarItem = tabBar.items?[index].value(forKey: "view") as? UIView {
             tabBarItem.transform = CGAffineTransform.identity.scaledBy(x: 1.3, y: 1.3)

             UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                 tabBarItem.transform = .identity
             }, completion: nil)
         }
         return true
     }
    
    private func setupTabs() {
        let breeds = BreedsViewController()
        let facts = FactsViewController()
        let game = GameViewController()
        let fav = FavoriteViewController()
        let settings = SettingsViewController()

        let mainNav = createNav(with: "Breeds", and: UIImage(named: "tabMonkey"), vc: breeds)
        let enycloNav = createNav(with: "Facts", and: UIImage(named: "tabFact"), vc: facts)
        let quizNav = createNav(with: "Game", and: UIImage(named: "tabGame"), vc: game)
        let settingNav = createNav(with: "Settings", and: UIImage(systemName: "gearshape.fill"), vc: settings)
        let favNav = createNav(with: "Favorites", and: UIImage(systemName: "heart.fill"), vc: fav)


        self.setViewControllers([mainNav, enycloNav, quizNav, favNav, settingNav], animated: true)
    }

    
    private func createNav(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        vc.title = title
        return nav
    }
}

