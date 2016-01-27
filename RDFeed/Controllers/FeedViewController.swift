//
//  FeedViewController.swift
//  RDFeed
//
//  Created by Daniel Contreras on 1/27/16.
//  Copyright © 2016 Daniel Contreras. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    
    var articles = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.articles = ["One", "Two", "Three", "Four", "Five"]
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

// MARK: - UITableViewDataSource
extension FeedViewController: UITableViewDataSource {
    
    // Table view data source methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.articles[indexPath.row]
        cell.detailTextLabel?.text = "Sub \(self.articles[indexPath.row])"
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