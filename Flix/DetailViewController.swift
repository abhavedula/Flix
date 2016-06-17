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
    

    
    @IBOutlet weak var moviePoster: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    dispatch_async(dispatch_get_main_queue()){
                    
                    
                    self.moviePoster.alpha = 0.3
                    
                }}, completion: { (sucess) -> Void in
                        
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
