//
//  FeedViewController.swift
//  RDFeed
//
//  Created by Daniel Contreras on 1/27/16.
//  Copyright © 2016 Daniel Contreras. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import AVReachability
import DateTools

class FeedViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var articles = [NSManagedObject]()
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.table.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        if (Reachability.isConnectedToNetwork() == true) {
            self.activityIndicator.startAnimating()
            self.updateArticlesList()
        } else {
            self.articles = self.fetchArticles()
            self.table.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateArticlesList() {
        self.requestArticles({(results: [[String: AnyObject]]) -> Void in
            self.saveArticles(results)
            self.articles = self.fetchArticles()
            self.table.reloadData()
            
            if let refresh = self.refreshControl {
                refresh.endRefreshing()
            }
        })
    }
    
    func requestArticles(completion: (result: [[String: AnyObject]]) -> Void) {
        Alamofire.request(.GET, Constants.Web.FeedURL)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if let hits = JSON["hits"] as? [[String: AnyObject]] {
                        completion(result: hits)
                    }
                }
                self.activityIndicator.stopAnimating()
        }
    }
    
    func fetchArticles() -> [NSManagedObject]! {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "is_deleted == NO")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            return results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func saveArticles(hits: [[String: AnyObject]]) {
        for hit in hits {
            if let      author = hit["author"] as? String,
                created_at = hit["created_at"] as? String,
                story_title = hit["story_title"] as? String,
                story_url = hit["story_url"] as? String,
                story_id = hit["story_id"] as? Int {
                    let appDelegate =
                    UIApplication.sharedApplication().delegate as! AppDelegate
                    let managedContext = appDelegate.managedObjectContext
                    let entity = NSEntityDescription.entityForName("Article",
                        inManagedObjectContext:managedContext)
                    
                    let article = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                    article.setValue(story_id, forKey: "story_id")
                    article.setValue(author, forKey: "author")
                    article.setValue(self.getFormattedDate(created_at), forKey: "created_at")
                    article.setValue(story_title, forKey: "story_title")
                    article.setValue(story_url, forKey: "story_url")
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save \(error), \(error.userInfo)")
                    }
                    
            }
        }
    }
    
    func getFormattedDate(date: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.dateFromString(date)!
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "feedDetailSegue") {
            let destination : DetailViewController = segue.destinationViewController as! DetailViewController
            let selectedIndex = sender as! NSIndexPath
            destination.article = self.articles[selectedIndex.row]
        }
    }
    
    // MARK: - Actions
    func refresh(sender:AnyObject)
    {
        self.updateArticlesList()
    }
    
}

// MARK: - UITableViewDataSource
extension FeedViewController: UITableViewDataSource {
    
    // Table view data source methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath)
        
        let author = self.articles[indexPath.row].valueForKey("author") as! String
        let created_at = self.articles[indexPath.row].valueForKey("created_at") as! NSDate
        let created_atText = created_at.timeAgoSinceNow()
        let story_title = self.articles[indexPath.row].valueForKey("story_title") as! String
        
        cell.textLabel?.text = story_title
        cell.textLabel?.lineBreakMode = .ByWordWrapping
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.text = "\(author) - \(created_atText)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.articles.count
    }
}

// MARK: - UITableViewDelegate
extension FeedViewController: UITableViewDelegate {
    
    // Table view delegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("feedDetailSegue", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let article = self.articles[indexPath.row]
            self.articles.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            article.setValue(NSNumber(bool: true)	, forKey: "is_deleted")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
}