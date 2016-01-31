//
//  DetailViewController.swift
//  RDFeed
//
//  Created by Daniel Contreras on 1/27/16.
//  Copyright © 2016 Daniel Contreras. All rights reserved.
//

import UIKit
import CoreData
import AVReachability

class DetailViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyState: UILabel!
    
    var article: NSManagedObject!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = NSURL(string: (self.article.valueForKey("story_url") as? String)!)
        
        self.emptyState.hidden = true
        if (Reachability.isConnectedToNetwork() == true) {
            let request = NSURLRequest(URL: url!)
            self.title = self.article.valueForKey("story_title") as? String
            self.activityIndicator.startAnimating()
            self.webView.loadRequest(request)
        } else {
            self.emptyState.hidden = false
        }
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

extension DetailViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        self.activityIndicator.stopAnimating()
    }
}
