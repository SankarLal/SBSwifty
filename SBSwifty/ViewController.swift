//
//  ViewController.swift
//  SBSwifty
//
//  Created by SANKARLAL on 28/10/15.
//  Copyright © 2015 SANKARLAL. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    var responseArray  = [String]()
    var filterResponseArray = [String]()
    
    var tblView : UITableView!
    var searchController : UISearchController?
    
    var isFilterText  = false
    
    
    // MARK: Life Style
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "HOME"
        setUpUserInterface()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        webServicesGetCall()
    }
    
    // MARK: Perform WebService Call
    func webServicesGetCall () {
        
        SBSwiftyService.getGeonames(SERVER_NAME as String,
            completion: { (result) -> Void in
                
                let responseData:NSDictionary? = result as? NSDictionary
                print(responseData)
                if let _ = responseData?.valueForKey("geonames") {
                    self.responseArray = responseData?.valueForKey("geonames")?.valueForKey("toponymName") as! Array
                } else {
                    self.responseArray = ["USA", "Bahamas", "Brazil", "Canada", "Republic of China", "Cuba", "Egypt", "Fiji", "France", "Germany", "Iceland", "India", "Indonesia", "Jamaica", "Kenya", "Madagascar", "Mexico", "Nepal", "Oman", "Pakistan", "Poland", "Singapore", "Somalia", "Switzerland", "Turkey", "UAE", "Vatican City"]
                }
                print(self.responseArray)
                dispatch_async(dispatch_get_main_queue()) {
                    self.tblView.reloadData()
                }
                
            }, failure: { (result) -> Void in
                print("failure \(result?.localizedDescription)")
                
        })
        
    }
    
    // MARK: SetUp User Interface
    func setUpUserInterface() {
        
        tblView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Plain)
        tblView.delegate = self
        tblView.dataSource = self
        tblView.showsVerticalScrollIndicator = false
        tblView.backgroundColor = UIColor.clearColor()
        tblView.tableHeaderView?.userInteractionEnabled = true
        tblView.tableFooterView = UIView(frame: CGRectZero)
        self.view.addSubview(tblView)
        
        searchController = UISearchController (searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.delegate = self;
        self.definesPresentationContext = true
        searchController!.searchBar.sizeToFit()
        tblView.tableHeaderView = searchController!.searchBar
        self.tblView.reloadData()
        
        
    }
    
    // MARK: ALL DELEGATE FUNCTIONS
    // MARK: TableView Delegate And DataSource Function
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isFilterText {
            return (filterResponseArray.count)
            
        } else {
            return (responseArray.count)
        }
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CELL-IDENTIFIER"
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell (style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        if isFilterText {
            cell!.textLabel!.text =  filterResponseArray[indexPath.section]
            
        } else {
            
            cell!.textLabel!.text =  responseArray[indexPath.section]
        }
        
        return cell!
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tblView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    // MARK: SearchBar Delegate Function
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            isFilterText = false
        } else {
            isFilterText = true
            filterTableViewForEnterText(searchText)
            
        }
        
        tblView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isFilterText = false
        tblView.reloadData()
        
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(self.searchController!)
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //        print("updateSearchResultsForSearchController")
        //        self.filterTableViewForEnterText(self.searchController!.searchBar.text!)
        //        tblView.reloadData()
        
    }
    
    func filterTableViewForEnterText(searchText: String) {
        
        self.filterResponseArray = self.responseArray.filter({( strCountry : String) -> Bool in
            let stringForSearch = strCountry.rangeOfString(searchText)
            return (stringForSearch != nil)
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

