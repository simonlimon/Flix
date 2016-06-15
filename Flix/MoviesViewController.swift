//
//  MoviesViewController.swift
//  Flix
//
//  Created by Simon Posada Fishman on 6/15/16.
//  Copyright © 2016 Simon Posada Fishman. All rights reserved.
//

import UIKit
import AFNetworking
import M13ProgressSuite

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSURLSessionDelegate,NSURLSessionDataDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var buffer:NSMutableData = NSMutableData()
    var session:NSURLSession?
    var dataTask:NSURLSessionDataTask?
    var expectedContentLength = 0
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        let apiKey = "15fa6ce390bb4ac774199a704013a70f"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        
//        progress.progress = 0.0
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let manqueue = NSOperationQueue.mainQueue()
        session = NSURLSession(configuration: configuration, delegate:self, delegateQueue: manqueue)
        dataTask = session?.dataTaskWithRequest(NSURLRequest(URL: url!))
        dataTask?.resume()
        
//        let request = NSURLRequest(
//            URL: url!,
//            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
//            timeoutInterval: 10)
//        
//        let session = NSURLSession(
//            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
//            delegate: nil,
//            delegateQueue: NSOperationQueue.mainQueue()
//        )
//        
//        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
//                                                                     completionHandler: { (dataOrNil, response, error) in
//                                                                        if let data = dataOrNil {
//                                                                            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
//                                                                                data, options:[]) as? NSDictionary {
//                                                                                print("response: \(responseDictionary)")
//                                                                                
//                                                                                self.movies = responseDictionary["results"] as? [NSDictionary]
//                                                                                
//                                                                                self.tableView.reloadData()
//                                                                                
//                                                                            }
//                                                                        }
//        })
//        task.resume()
    }
    
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        //here you can get full lenth of your content
        expectedContentLength = Int(response.expectedContentLength)
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        
        buffer.appendData(data)
        
        let percentageDownloaded = Float(buffer.length) / Float(expectedContentLength)
//        progress.progress =  percentageDownloaded
    }
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        //use buffer here.Download is done
//        progress.progress = 1.0   // download 100% complete
        
            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                buffer, options:[]) as? NSDictionary {
                print("response: \(responseDictionary)")
                
                self.movies = responseDictionary["results"] as? [NSDictionary]
                
                self.tableView.reloadData()
                
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
        cell.posterView.setImageWithURL(imageURL!)
        
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
