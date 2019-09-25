import UIKit

class ViewController: UIViewController {

    @IBOutlet var cardsCollectionView: UICollectionView!
    
    var cards = [MagicCard]() {
        didSet {
            cardsCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        loadCards()
    }
    
    private func configureCollectionView() {
        cardsCollectionView.dataSource = self
        cardsCollectionView.delegate = self
    }
    
    private func loadCards() {
        MagicCardAPIClient.manager.getCards { [weak self] (result) in
            switch result {
            case let .success(cards):
                self?.cards = cards
            case let .failure(error):
                print("An error occurred: \(error)")
            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // https://stackoverflow.com/questions/37152071/landscape-orientation-for-collection-view-in-swift/37152739
        let orientation = UIApplication.shared.statusBarOrientation
        
        if (orientation == .landscapeLeft || orientation == .landscapeRight) {
            return CGSize(width: (collectionView.bounds.width - 10) / 2, height: collectionView.bounds.width / 2.2)
        }
        else {
            return CGSize(width: (collectionView.bounds.width - 5) / 2, height: (collectionView.bounds.width / 1.5))
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "magicCardCell", for: indexPath) as? MagicCardCollectionViewCell else {
            fatalError("Unknown resuse ID")
        }
        let magicCard = cards[indexPath.row]
        cell.cardImageView.image = nil
        
        let imageCompletionHandler: (Result<UIImage, AppError>) -> Void = { result in
            switch result {
            case let .success(image):
                cell.cardImageView.image = image
                cell.setNeedsLayout()
            case let .failure(error):
                print("An error occurred: ")
                print(error)
            }
        }
        
        if let cardImageUrl = magicCard.imageUrl {
            ImageAPIClient.manager.loadImage(from: cardImageUrl,
                                             completionHandler: imageCompletionHandler)
        } else {
            cell.cardImageView.image = UIImage(named: "totallyLostImage")
        }
        return cell
    }
}

