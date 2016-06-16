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

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    
    var filteredMovies: [NSDictionary]?
    
    var data: [String]!
    
    var filteredData: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        filteredMovies = movies
        
        
        
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
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
                                                                     completionHandler: { (dataOrNil, response, error) in
                                                                        if let data = dataOrNil {
                                                                            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                                                                data, options:[]) as? NSDictionary {
                                                                                print("response: \(responseDictionary)")
                                                                                
                                                                                self.movies = responseDictionary["results"] as! [NSDictionary]
                                                                                self.tableView.reloadData()
                                                                                
                                                                                
                                                                            }
                                                                        }
                                                                        MBProgressHUD.hideHUDForView(self.view, animated: true)
        })
        task.resume()
        
        
        

        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        

        // Do any additional setup after loading the view.
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
        
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
                                                                     completionHandler: { (dataOrNil, response, error) in
                                                                        if let data = dataOrNil {
                                                                            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                                                                data, options:[]) as? NSDictionary {
                                                                                print("response: \(responseDictionary)")
                                                                                
                                                                                self.movies = responseDictionary["results"] as! [NSDictionary]
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
        if let movies = movies {
            return movies.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        
        cell.titleLabel.text = title
        
        let overview = movie["overview"] as! String

        cell.overviewLabel.text = overview
        
        let baseUrl = "http://image.tmdb.org/t/p/w500/"
        
        let image = movie["poster_path"] as! String
        
        let imageUrl = NSURLRequest(URL: NSURL(string: baseUrl + image)!)
        
        //cell.posterView.setImageWithURL(imageUrl!)
        
        cell.posterView.setImageWithURLRequest(
            imageUrl,
            placeholderImage: nil,
            success: { (imageUrl, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = image
                    UIView.animateWithDuration(1, animations: { () -> Void in
                        cell.posterView.alpha = 1.0
                    })
                } else {
                    cell.posterView.image = image
                }
            },
            failure: { (imageUrl, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        return cell
    }
    

    
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        

        for i in 0 ..< movies!.count {
            data.append(movies![i]["title"] as! String)
            
        }
        print(data)


        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredData = data
            filteredMovies = movies
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = data.filter({(dataItem: String) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if dataItem.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        /*
        for var i = 0; i < filteredData!.count ; i += 1 {
            for var j = 0; j < movies!.count ; j += 1 {
                if (movies![j]["title"] as! String) == filteredData[i] {
                    filteredMovies?.append(movies![j])
                }
            }
            
        }
        */
        print(filteredData)
        tableView.reloadData()
    }
}
    
    
    



