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

class TFTableViewController: UITableViewController {
    
    // Array for holding all the blog posts scraped from TF
    var blogPosts:[BlogPost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get all articles from the frist three pages
        self.scrapeTorrentFreak()
        self.scrapeTorrentFreak(pageNumber: 2)
        self.scrapeTorrentFreak(pageNumber: 3)
        self.scrapeTorrentFreak(pageNumber: 4)
        self.scrapeTorrentFreak(pageNumber: 5)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Table view functions
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        self.tableView.reloadData()
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
        
        cell.backgroundImage.sd_setImage(with: URL(string: blogPost.postImageLink), placeholderImage: #imageLiteral(resourceName: "black_bg"))
        cell.dateLabel.text = blogPost.postDate
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
    
    // Connect to TF and get the HTML for the page
    // Pass the HTML to the parsing method once it is received
    func scrapeTorrentFreak(pageNumber: Int = 1) -> Void {
        var urlString = "https://www.torrentfreak.com/"
        
        if pageNumber != 1 {
            urlString += "page/\(pageNumber)"
        }
        
        Alamofire.request(urlString).responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                 self.parseHTML(html: html)
            }
        }
    }
    
    // Method for getting main article information from the main page
    // Title, post link, link to post leading image, date
    func parseHTML(html: String) -> Void {
        // HTML of whole page
        let html = html
        
        // XPaths to header, header image and each non-header article
        let headerXPath = "//*[@id=\"main\"]/article/header/a"
        let headerImageXPath = "//*[@id=\"feature-background\"]"
        let articleXpath = "//*[@id=\"main\"]/article/div/header/a"
        
        do {
            let doc = try HTMLDocument(string: html, encoding: String.Encoding.utf8)
            var header = doc.xpath(headerXPath)
            
            // If header is not empty then the page has one. Only the first page has a header
            if (header.count != 0) {
                let post = BlogPost()
                post.postTitle = header[0].children[0].stringValue
                post.postLink = "https://www.torrentfreak.com" + header[0].attr("href")!
                post.postDate = (header[0].nextSibling?.nextSibling?.children[1].children[0].stringValue)!
                
                var timeStamp = header[0].nextSibling?.nextSibling?.children[1].children[0].attr("datetime")
                let timeStampSub = timeStamp?.prefix(19)
                timeStamp = String(timeStampSub!)
                timeStamp = timeStamp?.replacingOccurrences(of: "-", with: "")
                timeStamp = timeStamp?.replacingOccurrences(of: ":", with: "")
                timeStamp = timeStamp?.replacingOccurrences(of: "T", with: "")
                post.postTimeStamp = Int(timeStamp!)!

                
                
                header = doc.xpath(headerImageXPath)
                let imageLink = header[0].attr("style")!
                let imageLinkStartIndex = imageLink.index(imageLink.startIndex, offsetBy: 23)
                let imageLinkEndIndex = imageLink.index(imageLink.endIndex, offsetBy: -2)
                let subImageLink = imageLink[imageLinkStartIndex..<imageLinkEndIndex]
                post.postImageLink = "https://www.torrentfreak.com" + subImageLink
                
                post.postContent = "There is soe text for post onfds"
                
                self.blogPosts.append(post)
            }
            
            let subArticles = doc.xpath(articleXpath)
            
            for i in subArticles {
                let post = BlogPost()
                post.postTitle = i.children[1].children[0].stringValue
                post.postLink = "https://www.torrentfreak.com" + i.attr("href")!
                post.postDate = (i.nextSibling?.nextSibling?.children[1].children[0].stringValue)!
                
                var timeStamp = i.nextSibling?.nextSibling?.children[1].children[0].attr("datetime")
                let timeStampSub = timeStamp?.prefix(19)
                timeStamp = String(timeStampSub!)
                timeStamp = timeStamp?.replacingOccurrences(of: "-", with: "")
                timeStamp = timeStamp?.replacingOccurrences(of: ":", with: "")
                timeStamp = timeStamp?.replacingOccurrences(of: "T", with: "")
                post.postTimeStamp = Int(timeStamp!)!
                
                
                let imageLink = i.children[0].attr("style")!
                let imageLinkStartIndex = imageLink.index(imageLink.startIndex, offsetBy: 23)
                let imageLinkEndIndex = imageLink.index(imageLink.endIndex, offsetBy: -2)
                let subImageLink = imageLink[imageLinkStartIndex..<imageLinkEndIndex]
                post.postImageLink = "https://www.torrentfreak.com" + subImageLink
                
                post.postContent = "There is soe text for post onfds"
                
                self.blogPosts.append(post)
            }
            
            self.sortBlogPosts()
            self.tableView.reloadData()
            
        } catch let error {
            print(error)
        }
    }
    
    func sortBlogPosts() -> Void {
        var count = 0
        
        while count < self.blogPosts.count {
            if count > 0 && self.blogPosts[count].postTimeStamp < self.blogPosts[count - 1].postTimeStamp {
                self.blogPosts.swapAt(count - 1, count)
                count -= 1
            } else {
                count += 1
            }
        }
        
        self.blogPosts.reverse()
        
        if self.blogPosts.count == 41 {
            for i in self.blogPosts {
                print(i.postTimeStamp)
            }
        }
        
    }
    
}

