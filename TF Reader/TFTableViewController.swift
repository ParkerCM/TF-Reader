//
//  TFTableViewController.swift
//  TF Reader
//
//  Created by Parker Madel on 8/27/16.
//  Copyright © 2016 Parker Madel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class TFTableViewController: UITableViewController, XMLParserDelegate {
    

    var parser: XMLParser = XMLParser()
    var blogPosts:[BlogPost] = []
    var postTitle: String = String()
    var postLink: String = String()
    var postContent: String = String()
    var eName: String = String()
    var imageLink: String = String()
    var postDate: String = String()
    var imageLinks = [String]() // Remove this and append image urls to the blogpost class
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url:URL = URL(string: "https://feeds.feedburner.com/TorrentFreak/")!
        parser = XMLParser(contentsOf: url)!
        parser.delegate = self
        parser.parse()
        
        for i in blogPosts{
            parseWithMercury(articleLink: i.postLink)
        }
        
    }
    
    // NSXML Parsing methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        eName = elementName
        if elementName == "item" {
            postTitle = String()
            postLink = String()
            postDate = String()
            postContent = String()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if(!data.isEmpty){
            if eName == "title" {
                postTitle += data
            }else if eName == "link" {
                postLink += data
            }else if eName == "pubDate" {
                postDate += data
            }else if eName == "content:encoded" {
                postContent += data
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let blogPost: BlogPost = BlogPost()
            blogPost.postTitle = postTitle
            blogPost.postLink = postLink
            blogPost.postDate = postDate
            blogPost.postContent = postContent
            blogPosts.append(blogPost)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Table view functions

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogPosts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let blogPost: BlogPost = blogPosts[indexPath.row]
        cell.titleLabel.text = blogPost.postTitle
        cell.titleLabel.numberOfLines = 0
        
        let styledDateText = styleDate(date: blogPost.postDate)
        cell.dateLabel.text = styledDateText

        
        if imageLinks.count != 0 {
            let imageLink = URL(string: imageLinks[indexPath.row])
            let data = try? Data(contentsOf: imageLink!)
            cell.backgroundImage.image = UIImage(data: data!)
        }
        
        
        return cell
    }
    
    
    // Segue function
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewpost" {
            let selectedRow = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row
            let blogPost: BlogPost = blogPosts[selectedRow!]
            //print("User selected \(selectedRow) and this stuff: \(blogPost.postTitle)")
            let viewController = segue.destination as! PostViewController
            viewController.postLink = blogPost.postLink
        }
    }

    // Date formatting
    
    func styleDate(date: String) -> String {
        
        var newDate: String = String()
        let dayDict = ["Sun":"Sunday", "Mon":"Monday", "Tue":"Tuesday", "Wed":"Wednesday", "Thu":"Thursday", "Fri":"Friday", "Sat":"Saturday"]
        let monthDict = ["Jan":"January", "Feb":"February", "Mar":"March", "Apr":"April", "May":"May", "Jun":"June", "Jul":"July", "Aug":"August", "Sep":"September", "Oct":"October", "Nov":"November", "Dec":"December"]
        let dayArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
        
        for i in dayDict {
            if date.contains(i.key) {
                newDate.append(i.value + ", ")
            }
        }
        
        for i in monthDict {
            if date.contains(i.key) {
                newDate.append(i.value)
            }
        }
        
        for i in dayArray {
            if date.contains(" " + i + " ") {
                newDate.append(" " + i)
            }
        }
        
        
        return newDate
    }
    
    // Parse with Mercury API. Currently justs grabs the lead image url. Use Mercury instad of NSXML Parser in future?
    
    func parseWithMercury(articleLink: String) -> Void {
        var imageLink: String!
        let url = URL(string: "https://mercury.postlight.com/parser?url=" + articleLink)
        var mutableURL = URLRequest(url: url!)
        mutableURL.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURL.setValue("rEkcz83eU9RyuksZ1DejVTNGxeLlcQqTLVRcysDj", forHTTPHeaderField: "x-api-key")
        
        
        Alamofire.request(mutableURL as URLRequestConvertible)
            .responseJSON { response in
                if response.result.isSuccess {
                    if let value = response.result.value {
                        let json = JSON(value)
                        DispatchQueue.main.async {
                            imageLink = json["lead_image_url"].string
                            if imageLink != nil {
                                self.imageLinks.append(imageLink)
                            }
                            else if imageLink == nil {
                                print("Error trying to append image link in parseWithMercury()")
                            }
                            
                            if self.imageLinks.count == 10 {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                else if response.result.isFailure {
                    print("Error: \(response.error)")
                }
                
        }
    }
}

