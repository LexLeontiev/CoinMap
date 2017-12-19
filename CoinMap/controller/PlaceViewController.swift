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
    @IBOutlet weak var catIcon: UIImageView!
    @IBOutlet weak var addressIcon: UIImageView!
    @IBOutlet weak var descIcon: UIImageView!
    @IBOutlet weak var catText: UILabel!
    @IBOutlet weak var descText: UILabel!
    @IBOutlet weak var addressText: UILabel!
    
    var placeId: Int!
    var place: Place?
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPlace(placeId!)
    }
    
    @IBAction func dismissPopup(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func setPlace(_ place: Place?) {
        self.place = place;
    }
    
    fileprivate func bindViews() {
        placeNameText.text = place?.placeName
        catText.text = place?.categoryName
    }
    
    fileprivate func deliverResult(_ data: Data) {
        self.place = JsonParser.parsePlace(data)
    }
    
    func loadPlace(_ id: Int) {
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
