//
//  TFTableViewController.swift
//  TF Reader
//
//  Created by Parker Madel on 8/27/16.
//  Copyright © 2016 Parker Madel. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import Fuzi


class TFTableViewController: UITableViewController, XMLParserDelegate {
    
    var blogPosts:[BlogPost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavImage()
        self.scrapeTorrentFreak(pageNumber: 2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Table view functions
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogPosts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.isNotLoaded()
        let blogPost: BlogPost = blogPosts[indexPath.row]
        
        cell.backgroundImage.sd_setImage(with: URL(string: blogPost.postImageLink))
        cell.dateLabel.text = "January 31, 2018"
        cell.titleLabel.text = blogPost.postTitle
        cell.isLoaded()
        
        return cell
    }
    
    
    // Segue function
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewpost" {
            let selectedRow = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row
            let blogPost: BlogPost = blogPosts[selectedRow!]
            let viewController = segue.destination as! PostViewController
            viewController.postHTML = createHTMLForArticle(post: blogPost)
        }
    }
    
    func createHTMLForArticle(post: BlogPost) -> String {
        
        let var1 = post.postContent.replacingOccurrences(of: "\\n", with: "")
        let var2 = var1.replacingOccurrences(of: "\\" + "\"entry-lead" + "\\\"", with: "\"entry-lead\"")
        let var3 = var2.replacingOccurrences(of: "src=\\", with: "src=")
        let var4 = var3.replacingOccurrences(of: ".jpg\\", with: ".jpg")
        let var5 = var4.replacingOccurrences(of: ".png\\", with: ".png")
        let var6 = var5.replacingOccurrences(of: "\\" + "\"entry-content" + "\\\"", with: "\"entry-content\"")
        let var7 = var6.replacingOccurrences(of: "feedproxy.google.com", with: "torrentfreak.com")
        
        
        let finishedhtml = "<!DOCTYPE html><html><head><style>body{background-image: url('http://i.imgur.com/ur6nqAJ.png');background-repeat: repeat-y;font-family: 'Avenir Black';}.entry-content img{display: block;margin: auto;width: auto;position: relative;overflow: visible;border-radius: 8px;border: 5px solid #ddd;}p.entry-lead{font-weight: bold;}h1{text-align: center;}h1{background: url('" + post.postImageLink + "');margin: 0;padding: 0;}</style><h1>" + post.postTitle + "</h1>" + var7 + "</head></html>"
        
        return finishedhtml
    }
    
    func setNavImage() -> Void {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "tfNavBar"))
    }
    
    // New Methods
    func scrapeTorrentFreak(pageNumber: Int = 0) -> Void {
        var urlString = "https://www.torrentfreak.com/"
        
        if pageNumber != 0 {
            urlString += "page/\(pageNumber)"
        }
        
        Alamofire.request(urlString).responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.parseHTML(html: html)
            }
        }
    }
    
    func parseHTML(html: String) -> Void {
        let html = html
        let headerXPath = "//*[@id=\"main\"]/article/header/a/h1"
        //let articleXpath = "//*[@id=\"main\"]/article/div/header/a/div[2]/h1"
        let articleXpath = "//*[@id=\"main\"]/article/div/header/a"
        var count = 1
        
        do {
            let doc = try HTMLDocument(string: html, encoding: String.Encoding.utf8)
            
            let header = doc.xpath(headerXPath)
            
            for i in header {
                print("Count: \(count): " + i.stringValue)
                count += 1
            }
            
            let subArticles = doc.xpath(articleXpath)
            
            for i in subArticles {
                let post = BlogPost()
                post.postTitle = i.children[1].children[0].stringValue
                post.postLink = "https://www.torrentfreak.com" + i.attr("href")!
                
                let imageLink = i.children[0].attr("style")!
                let imageLinkStartIndex = imageLink.index(imageLink.startIndex, offsetBy: 23)
                let imageLinkEndIndex = imageLink.index(imageLink.endIndex, offsetBy: -2)
                let subImageLink = imageLink[imageLinkStartIndex..<imageLinkEndIndex]
                post.postImageLink = "https://www.torrentfreak.com" + subImageLink
                
                // fuck me
                post.postContent = "There is soe text for post onfds"
                
                self.blogPosts.append(post)
                //print("Count: \(count): " + post.postTitle + post.postLink + post.postImageLink)
                count += 1
            }
            
            self.tableView.reloadData()
            print("the count of posts is \(self.blogPosts.count)")

        } catch let error {
            print(error)
        }
    }
}

