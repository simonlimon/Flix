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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]!

    let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=15fa6ce390bb4ac774199a704013a70f")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.clearColor()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchBar.delegate = self
        filteredMovies = movies
        
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 0
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
    
    func resetProgressView() {
        let TIME_DELAY_BEFORE_HIDING_PROGRESS_VIEW: UInt32 = 2
        // Wait for couple of seconds so that user can see that the progress view has finished and then hide.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            sleep(TIME_DELAY_BEFORE_HIDING_PROGRESS_VIEW)
            dispatch_async(dispatch_get_main_queue(), {
                self.progressView.setProgress(0, animated: false)     // set the progress view to 0
            })
        })
    }
    
    func downloadMovieInfo(refreshControl: UIRefreshControl?) {
        pageCounter = 1
        progressView.progress = 0.0
        Alamofire.request(.GET, url!).progress{ bytesRead, totalBytesRead, totalBytesExpectedToRead in
//            print(totalBytesRead)
            dispatch_async(dispatch_get_main_queue()) {
                let progress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
                self.progressView.setProgress(progress, animated: true)
            }
            
            }.responseJSON { response in
                
                switch response.result {
                    
                case .Success(let JSON):
                    print("Success with JSON: \(JSON)")
                    let response = JSON as! NSDictionary
                    
                    self.movies = response["results"] as? [NSDictionary]
                    if (self.searchBar.text == "") {
                        self.filteredMovies = self.movies
                    }

                    self.tableView.reloadData()
                    
                    self.errorView.hidden = true
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    self.errorView.hidden = false
                }
                
                self.resetProgressView()
                
                if (refreshControl != nil) {
                    refreshControl!.endRefreshing()
                }
                
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // ------------------------ Infinite Scroll ------------------------
    
    var isMoreDataLoading = false
    var pageCounter = 1
    
    func loadMoreData() {
        self.pageCounter += 1
        progressView.progress = 0.0
        let pagedURL = (url?.absoluteString)! + "&page=" + String(pageCounter)
        Alamofire.request(.GET, pagedURL).progress{ bytesRead, totalBytesRead, totalBytesExpectedToRead in
//            print(totalBytesRead)
            dispatch_async(dispatch_get_main_queue()) {
                let progress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
                self.progressView.setProgress(progress, animated: true)
            }
            
            }.responseJSON { response in
                
                switch response.result {
                    
                case .Success(let JSON):
                    print("Success with JSON: \(JSON)")
                    let response = JSON as! NSDictionary
                    
                    self.movies?.appendContentsOf(response["results"] as! [NSDictionary])
                    if (self.searchBar.text == "") {
                        self.filteredMovies = self.movies
                    }

                    if self.collectionView.hidden {
                        self.tableView.reloadData()
                    } else {
                        self.collectionView.reloadData()
                    }
                    self.errorView.hidden = true
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    self.errorView.hidden = false
                }
                
                self.resetProgressView()

                self.isMoreDataLoading = false
                
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            var scrollViewContentHeight: CGFloat = 0
            var scrollOffsetThreshold: CGFloat = 0
            
            if (collectionView.hidden) {
                scrollViewContentHeight = tableView.contentSize.height
                scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            } else {
                scrollViewContentHeight = collectionView.contentSize.width
                scrollOffsetThreshold = scrollViewContentHeight - collectionView.bounds.size.width

            }
            
            // When the user has scrolled past the threshold, start requesting
            if(((scrollView.contentOffset.y > scrollOffsetThreshold) || (scrollView.contentOffset.x > scrollOffsetThreshold)) && (tableView.dragging || collectionView.dragging)) {
                isMoreDataLoading = true
                
                loadMoreData()
//                print("request")
            }
            
        }
    }
    
    
    // ------------------------ Table View ------------------------
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies?.count ?? 0
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let rating = movie["vote_average"] as! Double
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.setCircleColor(rating * 10)
        cell.ratingLabel.text = String(rating)
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        if let filePath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: baseURL + filePath)
            
            Alamofire.request(.GET, (imageURL?.absoluteString)!).progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
//                print(totalBytesRead)
                dispatch_async(dispatch_get_main_queue()) {
                    let progress = CGFloat(totalBytesRead) / CGFloat(totalBytesExpectedToRead)
                    cell.circleProgressView.setProgress(progress, animated: true)
                    cell.posterView.image = nil
                    
                }
                
                }.responseImage { response in
                    
                    if let image = response.result.value {
//                        print("image downloaded: \(image)")
                        cell.posterView.image = image.af_imageRoundedIntoCircle()
                    }
            }
        }
        
        
        cell.selectionStyle = .None
//        cell.titleLabel.sizeToFit()

        return cell
    }
    
    
    // ------------------------ Collection View ------------------------
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as! CollectionCell
        
        let movie = filteredMovies![indexPath.row]
        let popularity = movie["popularity"] as! Float
        let finalAlpha = CGFloat(popularity/35 * 0.7 + 0.3)
        let imageSize: CGFloat = CGFloat(100)

        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        if let filePath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: baseURL + filePath)
            let imageRequest = NSURLRequest(URL: imageURL!)

            cell.movieImage.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.movieImage.alpha = 0.0
                        cell.movieImage.image = image.af_imageAspectScaledToFillSize((CGSizeMake(imageSize-2, imageSize*1.5)))
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.movieImage.alpha = finalAlpha
                        })
                    } else {
                        print("Image was cached so just update the image")
                        
                        cell.movieImage.image = image.af_imageAspectScaledToFillSize((CGSizeMake(imageSize-1, imageSize*1.5)))
                        cell.movieImage.alpha = finalAlpha
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
            
            
        } else {
            cell.movieImage.image = nil
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
    
    // ------------------------ Search Bar ------------------------
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        print("hello")
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredMovies = movies!.filter({(dataItem: NSDictionary) -> Bool in
                // If dataItem matches the searchText, return true to include it
                let title = dataItem["title"] as! String
                return title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredMovies = movies
        tableView.reloadData()
    }
    
    
    // ------------------------ Detailed View ------------------------
    
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! DetailsViewController
        let indexPath: NSIndexPath?
        if (collectionView.hidden) {
            indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        } else {
            indexPath = collectionView.indexPathForCell(sender as! UICollectionViewCell)
        }
        
        let movie = filteredMovies![indexPath!.row]
        if let filePath = movie["poster_path"] as? String {
            vc.posterURL = filePath
        }
     }
}
