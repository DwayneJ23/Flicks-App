//
//  CollectionViewController.swift
//  MovieViewer
//
//  Created by Dwayne Johnson on 2/12/17.
//  Copyright © 2017 Dwayne Johnson. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var searchController: UISearchController!
    var endpoint = String()

    // Initialize a UIRefreshControl
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = UIColor.black

        filteredMovies = movies
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        collectionView.insertSubview(refreshControl, at: 0)
        
        
        // Create search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        
        
        // Place search bar in navigation bar
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        
        // Grab data from API
        networkRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let movies = filteredMovies {
            return movies.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomMovieCell", for: indexPath) as! CustomCollectionViewCell
        let movie = filteredMovies![indexPath.row]
        
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        
        // ...Fade image loaded from the network...
        let imageRequest = NSURLRequest(url: NSURL(string: baseUrl + posterPath)! as URL)
        
        cell.posterImage.setImageWith(imageRequest as URLRequest, placeholderImage: nil, success: {(imageRequest, imageResponse, image) -> Void in
            
            // imageResponse will be nil if the image is cached
            if imageResponse != nil {
                print("Image was NOT cached, fade in image")
                cell.posterImage.alpha = 0.0
                cell.posterImage.image = image
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    cell.posterImage.alpha = 1.0
                })
            } else {
                print("Image was cached so just update the image")
                cell.posterImage.image = image
            }
        },
                                      failure: { (imageRequest, imageResponse, error) -> Void in
                                        // do something for the failure condition
        })
        return cell
    }
    
    func networkRequest()
    {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        // Diplay HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.filteredMovies = dataDictionary["results"] as? [NSDictionary]
                    
                    // Reload tableView with new data
                    self.collectionView.reloadData()
                    
                    // Hide HUD once the network request comes back (must be done on main UI thread)
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    // Tell the refreshControl to stop spinning
                    self.refreshControl.endRefreshing()
                }
            }
        }
        task.resume()
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        if let searchText = searchController.searchBar.text
        {
            filteredMovies = searchText.isEmpty ? movies : movies?.filter({(dataString: NSDictionary) -> Bool in
                let title = dataString["title"] as! String
                return title.range(of: searchText, options: .caseInsensitive) != nil
            })
            
            collectionView.reloadData()
        }
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl)
    {
        networkRequest()
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        

        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        let movie = filteredMovies![indexPath!.row]
            
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        detailViewController.hidesBottomBarWhenPushed = true
        
    }
    
    
}
