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

class FeedViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    
    var articles = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if (Reachability.isConnectedToNetwork() == true) {
            self.requestArticles()
        } else {
            self.articles = self.fetchArticles()
            self.table.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchArticles() -> [NSManagedObject]! {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Article")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            return results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func requestArticles() {
        Alamofire.request(.GET, Constants.Web.FeedURL)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if let hits = JSON["hits"] as? [[String: AnyObject]] {
                        for hit in hits {
                            if let
                                story_id = hit["story_id"] as? Int,
                                author = hit["author"] as? String,
                                created_at = hit["created_at"] as? String,
                                story_title = hit["story_title"] as? String,
                                story_url = hit["story_url"] as? String {
                                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                    let managedContext = appDelegate.managedObjectContext
                                    let entity = NSEntityDescription.entityForName("Article", inManagedObjectContext:managedContext)
                                    
                                    let article = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                                    article.setValue(author, forKey: "author")
                                    article.setValue(created_at, forKey: "created_at")
                                    article.setValue(story_title, forKey: "story_title")
                                    article.setValue(story_url, forKey: "story_url")
                                    article.setValue(story_id, forKey: "story_id")
                                    
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save \(error), \(error.userInfo)")
                                    }
                            }
                        }
                    }
                    self.articles = self.fetchArticles()
                    self.table.reloadData()
                }
        }
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

// MARK: - UITableViewDataSource
extension FeedViewController: UITableViewDataSource {
    
    // Table view data source methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath)
        
        let author = self.articles[indexPath.row].valueForKey("author") as! String
        let created_at = self.articles[indexPath.row].valueForKey("created_at") as! String
        let story_title = self.articles[indexPath.row].valueForKey("story_title") as! String
        
        cell.textLabel?.text = story_title
        cell.textLabel?.lineBreakMode = .ByWordWrapping
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.text = "\(author) - \(created_at)"
        
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
        //self.performSegueWithIdentifier("segue", sender: indexPath)
    }
}