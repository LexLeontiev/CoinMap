//
//  PlaceViewController.swift
//  CoinMap
//
//  Created by Lex Leontiev on 18/12/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import UIKit

class PlaceViewController: UIViewController {
        
    @IBOutlet weak var placeNameText: UILabel!
    @IBOutlet weak var catText: UILabel!
    @IBOutlet weak var addressText: UILabel!
    @IBOutlet weak var websiteText: UILabel!
    @IBOutlet weak var countryText: UILabel!
    @IBOutlet weak var descText: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    var placeManager: DataManagerProtocol!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var placeId: Int!
    var place: Place?
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load core data place manager
        self.placeManager = CoreDataManager(context: context)
    
        loadPlace(placeId!)
    }
    
    //Actions
    @IBAction func dismissPopup(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setIsFavorite(_ sender: Any) {
        if (place?.isFavorite)! {
            place?.isFavorite = false
            self.placeManager.removePlace(id: (place?.id)!)
            favoriteBtn.setImage(UIImage(named: "icons8-star-white-100.png"), for: UIControlState.normal)
        } else {
            place?.isFavorite = true
            self.placeManager.savePlace(place: place!)
            favoriteBtn.setImage(UIImage(named: "icons8-star-filled-white-100.png"), for: UIControlState.normal)
        }
    }
    
    //Setters
    func setPlace(_ place: Place?) {
        self.place = place;
    }
    
    //Methods
    fileprivate func bindViews() {
        favoriteBtn.isEnabled = true
        if place?.placeName != nil {
            placeNameText.text = place?.placeName
        }
        if place?.categoryName != nil && place?.categoryName != ""  {
            catText.text = place?.categoryName
        }
        if place?.address != nil && place?.address != "" {
            addressText.text = place?.address
        }
        if place?.website != nil && place?.website != "" {
            websiteText.text = place?.website
        }
        if place?.country != nil && place?.country != "" {
            countryText.text = place?.country
        }
        if place?.desc != nil && place?.desc != "" {
            descText.text = place?.desc
        }
        if (place?.isFavorite)! {
            favoriteBtn.setImage(UIImage(named: "icons8-star-filled-white-100.png"), for: UIControlState.normal)
        } else {
            favoriteBtn.setImage(UIImage(named: "icons8-star-white-100.png"), for: UIControlState.normal)
        }
    }
    
    fileprivate func deliverResult(_ data: Data) {
        self.place = JsonParser.parsePlace(data)
        self.place?.isFavorite = self.placeManager.checkPlace(id: (place?.id)!)
    }
    
    fileprivate func loadPlace(_ id: Int) {
        dataTask?.cancel()
        if var urlComponents = URLComponents(string: "https://coinmap.org/api/v1/venues/\(id)") {
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.deliverResult(data)
                        self.bindViews()
                    }
                }
            }
            dataTask?.resume()
        }
    }
}
