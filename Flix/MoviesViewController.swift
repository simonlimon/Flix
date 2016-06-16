//
//  MoviesViewController.swift
//  Flix
//
//  Created by Simon Posada Fishman on 6/15/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import AFNetworking
import Alamofire
import AlamofireImage

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=15fa6ce390bb4ac774199a704013a70f")
        
        Alamofire.request(.GET, url!).responseJSON { response in switch response.result {
                case .Success(let JSON):
                    print("Success with JSON: \(JSON)")
                    let response = JSON as! NSDictionary
            
                    self.movies = response["results"] as? [NSDictionary]
                    
                    self.tableView.reloadData()
            
                case .Failure(let error):
                    print("Request failed with error: \(error)")
            }
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }

    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        let filePath = movie["poster_path"] as! String
        
        let imageURL = NSURL(string: baseURL + filePath)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview

        Alamofire.request(.GET, (imageURL?.absoluteString)!).progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
            print(totalBytesRead)
            dispatch_async(dispatch_get_main_queue()) {
                let progress = CGFloat(totalBytesRead) / CGFloat(totalBytesExpectedToRead)
                cell.circleProgressView.setProgress(progress, animated: true)
                cell.posterView.image = nil

            }
            
            }.responseImage { response in
    
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    cell.posterView.image = image.af_imageRoundedIntoCircle()
                }
            }
        
        return cell
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
