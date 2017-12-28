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
        super.viewDidLoad()
        self.title = "HOME"
        setUpUserInterface()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webServicesGetCall()
    }
    
    // MARK: Perform WebService Call
    func webServicesGetCall () {
        
        SBSwiftyService.getGeonames(GEO_NAMES_SERVICE,
            completion: { (result) -> Void in
                
                let responseData : NSDictionary? = result as? NSDictionary
                if let _ = responseData?.value(forKey: "geonames") {
                    self.responseArray = (responseData?.value(forKey: "geonames") as AnyObject).value(forKey: "toponymName") as! Array
                } else {
                    self.responseArray = ["USA", "Bahamas", "Brazil", "Canada", "Republic of China", "Cuba", "Egypt", "Fiji", "France", "Germany", "Iceland", "India", "Indonesia", "Jamaica", "Kenya", "Madagascar", "Mexico", "Nepal", "Oman", "Pakistan", "Poland", "Singapore", "Somalia", "Switzerland", "Turkey", "UAE", "Vatican City"]
                }
                print(self.responseArray)
                DispatchQueue.main.async {
                    self.tblView.reloadData()
                }
                
            }, failure: { (result) -> Void in
                print("failure \(String(describing: result?.localizedDescription))")
                
        })
        
    }
    
    // MARK: SetUp User Interface
    func setUpUserInterface() {
        
        tblView = UITableView(frame: self.view.bounds, style: UITableViewStyle.plain)
        tblView.delegate = self
        tblView.dataSource = self
        tblView.showsVerticalScrollIndicator = false
        tblView.backgroundColor = UIColor.clear
        tblView.tableHeaderView?.isUserInteractionEnabled = true
        tblView.tableFooterView = UIView(frame: CGRect.zero)
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
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFilterText {
            return (filterResponseArray.count)
            
        } else {
            return (responseArray.count)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CELL-IDENTIFIER"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell (style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        if isFilterText {
            cell!.textLabel!.text =  filterResponseArray[indexPath.section]
            
        } else {
            
            cell!.textLabel!.text =  responseArray[indexPath.section]
        }
        
        return cell!
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tblView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: SearchBar Delegate Function
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            isFilterText = false
        } else {
            isFilterText = true
            filterTableViewForEnterText(searchText)
            
        }
        
        tblView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFilterText = false
        tblView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: self.searchController!)
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        //        print("updateSearchResultsForSearchController")
        //        self.filterTableViewForEnterText(self.searchController!.searchBar.text!)
        //        tblView.reloadData()
        
    }
    
    func filterTableViewForEnterText(_ searchText: String) {
        
        self.filterResponseArray = self.responseArray.filter({( strCountry : String) -> Bool in
            let stringForSearch = strCountry.range(of: searchText)
            return (stringForSearch != nil)
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

