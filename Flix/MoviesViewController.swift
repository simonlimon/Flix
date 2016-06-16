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
import UAProgressView

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var movies: [NSDictionary]?
    let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=15fa6ce390bb4ac774199a704013a70f")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)

        downloadMovieInfo(nil)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        downloadMovieInfo(refreshControl)
    }
    
    func downloadMovieInfo(refreshControl: UIRefreshControl?) {
        progressView.progress = 0.0
        Alamofire.request(.GET, url!).progress{ bytesRead, totalBytesRead, totalBytesExpectedToRead in
            print(totalBytesRead)
            dispatch_async(dispatch_get_main_queue()) {
                let progress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
                self.progressView.setProgress(progress, animated: true)
            }
            
            }.responseJSON { response in switch response.result {
            case .Success(let JSON):
                print("Success with JSON: \(JSON)")
                let response = JSON as! NSDictionary
                
                self.movies = response["results"] as? [NSDictionary]
                
                self.tableView.reloadData()
                self.errorView.hidden = true
                if (refreshControl != nil) {
                    refreshControl!.endRefreshing()
                }
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                self.errorView.hidden = false
                if (refreshControl != nil) {
                    refreshControl!.endRefreshing()
                }
                
                }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // ------------------------ Table View ------------------------
    
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
    
    // ------------------------ Collection View ------------------------
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as! CollectionCell
        
        let movie = movies![indexPath.row]
        let baseURL = "http://image.tmdb.org/t/p/w500"
        let filePath = movie["poster_path"] as! String
        
        let imageURL = NSURL(string: baseURL + filePath)
        
        Alamofire.request(.GET, (imageURL?.absoluteString)!).progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
            print(totalBytesRead)
            dispatch_async(dispatch_get_main_queue()) {
//                cell.movieImage.image = nil
            }
            
            }.responseImage { response in
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    cell.movieImage.image = image.af_imageRoundedIntoCircle()
                }
        }
        
        return cell
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let totalwidth = collectionView.bounds.size.width;
//        let numberOfCellsPerRow = 3
//        let oddEven = indexPath.row / numberOfCellsPerRow % 2
//        let dimensions = CGFloat(Int(totalwidth) / numberOfCellsPerRow)
//        if (oddEven == 0) {
//            return CGSizeMake(dimensions, dimensions)
//        } else {
//            return CGSizeMake(dimensions, dimensions / 2)
//        }
//    }
    
    var toggle = true
    @IBAction func collectionButton(sender: UIButton) {
        if toggle {
            collectionView.hidden = false
            
            UIView.animateWithDuration(0.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                
                self.collectionView.alpha = 1.1
                
                }, completion: nil)
            
            collectionView.reloadData()
        } else {
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                
                self.collectionView.alpha = 0.0
                
                }, completion: {
                    (value: Bool) in
                    self.collectionView.hidden = true
            })
            
        }
        toggle = !toggle
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
