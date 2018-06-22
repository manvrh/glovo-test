//
//  ChangeCityTVC.swift
//  GlovoTest
//
//  Created by Manuel Vrhovac on 22/06/2018.
//  Copyright © 2018 Manuel Vrhovac. All rights reserved.
//

import UIKit

class ChangeCityTVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cm.countryDict.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cm.sortedCountryDict[section].value.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return cm.sortedCountryDict[section].key
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath)
        let city = cm.sortedCountryDict[indexPath.section].value[indexPath.row]
        let flag = String.flagEmojiForCountryCode(city.countryCode)
        cell.textLabel!.text = flag + " " + city.name
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let city = cm.sortedCountryDict[indexPath.section].value[indexPath.row]
        cm.selectedCity = city
        self.navigationController?.popViewController(animated: true)
    }
 
}
