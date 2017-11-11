//
//  ViewController.swift
//  CloudYak
//
//  Created by Jack Frysinger on 7/28/17.
//  Copyright © 2017 Jack Frysinger. All rights reserved.
//

import UIKit

class ViewController: UIViewController, YakModelDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let model = YakModel()
    
    var yaks = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        model.delegate = self
        model.refreshYaks()
        
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addYak(_ sender: Any) {
        let alert = UIAlertController(title: "Enter your message", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        var text = UITextField()
        alert.addTextField {(field) in text = field}
        alert.addAction(UIAlertAction(title: "Post", style: UIAlertActionStyle.default) {a in self.model.postYak(message: text.text!)})
        present(alert, animated: true, completion: nil)
    }
    
    func didRefreshYaks() {
        yaks = model.recentResults
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yaks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = yaks[indexPath.row]
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = content
        
        return cell
    }
    
    func failedToRefreshYaks() {
        showAlertWithText(title: "Could not refresh Yaks", message: "Check your network connection and try again")
    }
    
    func userLocationNotAvailable() {
        showAlertWithText(title: "Location unknown", message: "Check your location settings and try again")
    }
    
    func didPostYak() {
        showAlertWithText(title: "Yak Posted!", message: nil)
        model.refreshYaks()
    }
    
    func failedToPostYak() {
        showAlertWithText(title: "Failed to post yak", message: "Check your network connection and try again")
    }
    
    func showAlertWithText(title: String?, message: String?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        controller.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) {a in self.dismiss(animated: true, completion: nil)})
        present(controller, animated: true, completion: nil)
    }
        
}

