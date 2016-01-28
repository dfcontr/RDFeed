//
//  DetailViewController.swift
//  RDFeed
//
//  Created by Daniel Contreras on 1/27/16.
//  Copyright © 2016 Daniel Contreras. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var article: NSManagedObject!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = NSURL(string: (self.article.valueForKey("story_url") as? String)!)
        let request = NSURLRequest(URL: url!)
        self.title = self.article.valueForKey("story_title") as? String
        self.webView.loadRequest(request)
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