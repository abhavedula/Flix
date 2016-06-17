//
//  DetailViewController.swift
//  Flix
//
//  Created by Abha Vedula on 6/16/16.
//  Copyright © 2016 Abha Vedula. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class DetailViewController: UIViewController {
    
    var movieTitle: String?
    
    var smallImageUrl: NSURL!
    
    var largeImageUrl: NSURL!
    
    var overview: String!
    
    var movieId: String!
    
    var response: NSDictionary?
    
    var vidUrl: String?

    @IBAction func buyTicketsButton(sender: AnyObject) {
        
        let aString: String = movieTitle!
        let newString = aString.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        if let url = NSURL(string: "http://www.fandango.com/search?q=\(newString)&mode=general") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    
    @IBAction func watchTrailer(sender: AnyObject) {
        if let videoUrl = NSURL(string: "https://www.youtube.com/watch?v=\(vidUrl!)") {
            UIApplication.sharedApplication().openURL(videoUrl)
        }
    }
   
    
    @IBOutlet weak var moviePoster: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(apiKey)&append_to_response=releases,trailers")
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
                                       
                                                                                self.vidUrl = responseDictionary["trailers"]!["youtube"]!![0]!["source"]! as! String
                                                                                print(self.vidUrl!)
                                            
                                                                                
                                                                            }
                                                                        }
        })
        task.resume()
        
        
        
        
        
        
        titleLabel.text = movieTitle
        
        
        overviewLabel.text = overview
        
        
        let smallImageRequest = NSURLRequest(URL: smallImageUrl!)
        let largeImageRequest = NSURLRequest(URL: largeImageUrl!)
        
        self.moviePoster.setImageWithURLRequest(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                self.moviePoster.alpha = 0.0
                self.moviePoster.image = smallImage;
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    
                    self.moviePoster.alpha = 0.3
                    
                }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.moviePoster.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.moviePoster.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
        })
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
