//
//  MoviesViewController.swift
//  Flix
//
//  Created by Abha Vedula on 6/15/16.
//  Copyright © 2016 Abha Vedula. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD



class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var movieTitle: String!
    
    var imageUrl: NSURL!
    
    var smallImageUrl: NSURL!
    
    var largeImageUrl: NSURL!
        
    var overview: String!

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    
    var filteredMovies: [NSDictionary]?
    
    var selectedBackgroundView: UIView?
    
    var rating: String!
    
    var movieId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
        if let data = dataOrNil {
            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                print("response: \(responseDictionary)")
                self.movies = (responseDictionary["results"] as! [NSDictionary])
                self.filteredMovies = self.movies

                self.tableView.reloadData()
             }
        }
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        });
        task.resume()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Do any additional setup after loading the view.
        
        
        
        
        self.navigationItem.title = "Flix"
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.backgroundColor = UIColor(red: 0, green: 0.0, blue: 0.0, alpha: 0.1)
            navigationBar.tintColor = UIColor(red: 255, green: 0.0, blue: 0.0, alpha: 0.8)
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            shadow.shadowOffset = CGSizeMake(2, 2);
            shadow.shadowBlurRadius = 4;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(24),
                NSForegroundColorAttributeName : UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1),
                NSShadowAttributeName : shadow
            ]
        }
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)

        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                    print("response: \(responseDictionary)")
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()
                    refreshControl.endRefreshing()
                }
            }
        })
        task.resume()

                                                                                

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        movieTitle = movie["title"] as! String
        
        cell.titleLabel.text = movieTitle
        
        overview = movie["overview"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500/"
        
        let image = movie["poster_path"] as! String
                
        let imageUrlRequest = NSURLRequest(URL: NSURL(string: baseUrl + image)!)
        
        rating = String(movie["vote_average"]!)
        
        cell.ratingLabel.text = "Viewer rating: \(rating)"
        
//        imageUrl = NSURL(string: baseUrl + image)
//        
//        cell.posterView.setImageWithURL(imageUrl)
        
        cell.posterView.setImageWithURLRequest(
            imageUrlRequest,
            placeholderImage: nil,
            success: { (imageUrlRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                                    if imageResponse != nil {
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            
                            cell.posterView.alpha = 1.0
                            })
                    } else {
                        cell.posterView.image = image
                    }
                
            },
            failure: { (imageUrlRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.redColor()
        cell.selectedBackgroundView = backgroundView
 
        return cell
    }
    

    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredMovies = movies!.filter({(dataItem: NSDictionary) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if (dataItem["title"] as! String ).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        tableView.reloadData()
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        
        let movie = filteredMovies![indexPath!.row]
        movieTitle = movie["title"] as! String
 
        let detailViewController = segue.destinationViewController as! DetailViewController
        
        let baseUrlSmall = "https://image.tmdb.org/t/p/w45"
        
        let baseUrlLarge = "https://image.tmdb.org/t/p/original"
        
        let image = movie["poster_path"] as! String
        
        smallImageUrl = NSURL(string: baseUrlSmall + image)
        
        largeImageUrl = NSURL(string: baseUrlLarge + image)
        
        movieId = String(movie["id"]!)

        overview = movie["overview"] as! String
        
        detailViewController.movieTitle = self.movieTitle
        detailViewController.smallImageUrl = self.smallImageUrl
        detailViewController.largeImageUrl = self.largeImageUrl
        detailViewController.overview = self.overview
        detailViewController.movieId = self.movieId
        
        print(movieId)
    }
    
    
    
   }

    




