//
//  ViewController.swift
//  Todoey
//
//  Created by Daniela Lima on 2022-08-18.
//

import UIKit

//change UIViewController to UITableViewController
//As we've inherited UITableVIewController and added a tableViewController to the storyboard instead of a normal ViewController,
//we don't need to keep ViewController as a subclass of UIViewController, and link up any @IBOutlet or add the whole self.tableView.delegate to set ourselves as the delegate or data source,
//because all of is automated behind the scenes by XCode
class TodoListViewController: UITableViewController {
    
    let itemArray = ["Buy Eggs", "Buy tomatos", "make bread"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

//MARK: - TableView Datasource Methods
    
    //to specify how many rows we wanted in tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //to specify what cells should display
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        //label for every single cell
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    

}




