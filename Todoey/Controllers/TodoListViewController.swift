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
    
    //to use Item struct inside ViewController
    var itemArray = [Item]()
    
    //file path to Documents folder where items inckuded in to-do will be saved
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
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
        
        let item = itemArray[indexPath.row]
        
        //label for every single cell
        cell.textLabel?.text = item.title
        
        //to add or remove a checkmark on selected cell
        //Ternary operator ==>
        //value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        return cell
    }
    
//MARK: - TableView Delegate Methods
    
    //to detect which row was selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //to persist checking and unchecking data into plist
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
            
        //when selected, cell flashes gray and goes back to being deselected and white
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    //button to add new items to to-do list
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //this textField has the scope of the entire addButtonPressed IBAction
        //and it's accessible inside alert closures
        var textField = UITextField()
        
        //when addButton is pressed, it will display a pop-up with a text field
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        //button to press after finish writing
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newItem = Item()
            newItem.title = textField.text!
            //to append new items to the end of to-do-list
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        //to include a textField to pop-up alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        //to add action to alert
        alert.addAction(action)
        
        //to show alert
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        //to encode data for plist file
        let encoder = PropertyListEncoder()
        //do and catch block because this func can throw an error
        do {
            let data = try encoder.encode(itemArray)
            //to save encoded data into plist
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
        
        //to reload tableView and show the new added data
        self.tableView.reloadData()
    }
    
    func loadItems() {
        //to decode and load up data in to-do list from plist
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
            itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item Array, \(error)")
            }
        }
    }
}








