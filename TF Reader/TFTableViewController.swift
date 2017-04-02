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
import Kanna


class TFTableViewController: UITableViewController, XMLParserDelegate {
    
    var parser: XMLParser = XMLParser()
    var blogPosts:[BlogPost] = []
    var postTitle: String = String()
    var postLink: String = String()
    var postContent: String = String()
    var eName: String = String()
    var imageLink: String = String()
    var postDate: String = String()
    var storyTitle: String! = String()
    var storyTitles = [String]()
    var imageLinks = [String]() // Remove this and append image urls to the blogpost class
    var postContents = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url: URL = URL(string: "https://feeds.feedburner.com/TorrentFreak/")!
        parser = XMLParser(contentsOf: url)!
        parser.delegate = self
        parser.parse()
        self.tableView.isHidden = false
        setNavImage()
        
        for i in blogPosts{
            parseWithMercury(articleLink: i.postLink)
        }

        print(blogPosts.count)
    }
    
    // NSXML Parsing methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        eName = elementName
        if elementName == "item" {
            postTitle = String()
            postLink = String()
            postDate = String()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if(!data.isEmpty){
            if eName == "title" {
                postTitle += data
            } else if eName == "link" {
                postLink += data
            } else if eName == "pubDate" {
                postDate += data
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let blogPost: BlogPost = BlogPost()
            blogPost.postTitle = fixDateWithSpecialCharacters(title: postTitle)
            blogPost.postLink = postLink
            blogPost.postDate = styleDate(date: postDate)
            blogPosts.append(blogPost)
        }
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
        var index = 0
        
        let blogPost: BlogPost = blogPosts[indexPath.row]
        cell.titleLabel.text = blogPost.postTitle
        cell.titleLabel.numberOfLines = 0
        
        cell.dateLabel.text = blogPost.postDate
        
        if self.imageLinks.count < 10 {
            cell.isNotLoaded()
        } else {
            cell.isLoaded()
        }

        while index < (self.imageLinks.count) {
            if blogPost.postTitle == self.storyTitles[index] {
                blogPost.postImageLink = self.imageLinks[index]
                blogPost.postContent = self.postContents[index]
                index = 0
                break
            } else {
                index += 1
            }
        }
        
        if imageLinks.count != 0 {
            let imageLink = URL(string: blogPost.postImageLink)
            
            if let hereIsTheLinkGoodSir = imageLink {
                let data = try? Data(contentsOf: hereIsTheLinkGoodSir)
                if data != nil {
                    cell.backgroundImage.image = UIImage(data: data!)
                }
            }
        } else {
            print("Failed to use image link")
            cell.backgroundImage.image = #imageLiteral(resourceName: "keyboard")
            cell.backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        }
        
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

    // String formatting
    
    func styleDate(date: String) -> String {
        var newDate: String = String()
        let dayDict = ["Sun":"Sunday", "Mon":"Monday", "Tue":"Tuesday", "Wed":"Wednesday", "Thu":"Thursday", "Fri":"Friday", "Sat":"Saturday"]
        let monthDict = ["Jan":"January", "Feb":"February", "Mar":"March", "Apr":"April", "May":"May", "Jun":"June", "Jul":"July", "Aug":"August", "Sep":"September", "Oct":"October", "Nov":"November", "Dec":"December"]
        let dayNumDict = ["01":"1", "02":"2", "03":"3", "04":"4", "05":"5", "06":"6", "07":"7", "08":"8", "09":"9"]
        let dayNumArray = ["10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
        
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
        
        for i in dayNumDict {
            if date.contains(" " + i.key + " ") {
                newDate.append(" " + i.value)
            }
        }
        
        for i in dayNumArray {
            if date.contains(" " + i + " ") {
                newDate.append(" " + i)
            }
        }
        
        return newDate
    }
    
    func fixDateWithSpecialCharacters(title: String) -> String {
        let specChar1 = "‘"
        let specChar2 = "“"
        var newString: String = String()
        
        if title.contains(specChar1) || title.contains(specChar2) {
            var strArray = Array(title.characters)
            var singleIndices = [Int]()
            var doubleIndices = [Int]()
            var index = 0
            let max = title.characters.count
            
            while index < max {
                if strArray[index] == ("‘") {
                    singleIndices.append(index)
                    index += 1
                } else if strArray[index] == ("“") {
                    doubleIndices.append(index)
                    index += 1
                } else {
                    index += 1
                }
            }
            
            if !singleIndices.isEmpty {
                if singleIndices.count == 1 {
                    strArray.insert(" ", at: singleIndices[0])
                }
            } else {
                if doubleIndices.count == 1 {
                    strArray.insert(" ", at: doubleIndices[0])
                }
            }
            
            for i in strArray {
                newString.append(i)
            }
        } else {
            newString = title
        }
        return newString
    }
    
    // Parse with Mercury API. Currently justs grabs the lead image url. Use Mercury instad of NSXML Parser in future?
    
    func parseWithMercury(articleLink: String) -> Void {
        var imageLink: String!
        var postContent: String!
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
                            self.storyTitle = json["title"].string
                            postContent = json["content"].string
                            if imageLink != nil {
                                self.storyTitles.append(self.storyTitle)
                                self.imageLinks.append(imageLink)
                                self.postContents.append(postContent)
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
                    print("Error: \(String(describing: response.error))")
                }
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
        
        
        let finishedhtml = "<!DOCTYPE html><htm><head><style>body{background-image: url('http://i.imgur.com/ur6nqAJ.png');background-repeat: repeat-y;font-family: 'Avenir Black';}.entry-content img{display: block;margin: auto;width: auto;position: relative;overflow: visible;border-radius: 8px;border: 1px solid #ddd;}p.entry-lead{font-weight: bold;}h1{text-align: center;}</style><h1>" + post.postTitle + "</h1>" + var7 + "</head></html>"
        
        return finishedhtml
    }
    
    func setNavImage() -> Void {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "tfNavBar"))
    }
}

