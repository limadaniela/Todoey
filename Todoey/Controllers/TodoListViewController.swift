//
//  ViewController.swift
//  Todoey
//
//  Created by Daniela Lima on 2022-08-18.
//

import UIKit
import CoreData

//change UIViewController to UITableViewController
//As we've inherited UITableVIewController and added a tableViewController to the storyboard instead of a normal ViewController,
//we don't need to keep ViewController as a subclass of UIViewController, and link up any @IBOutlet or add the whole self.tableView.delegate to set ourselves as the delegate or data source,
//because all of is automated behind the scenes by XCode
class TodoListViewController: UITableViewController {
    
    //to use Item struct inside ViewController
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet{
            //load up all the to-do list items from database.
            loadItems()
        }
    }
    
    //to call AppDelegate methods inside TodoListViewController
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //file path to Documents folder where items inckuded in to-do will be saved
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
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
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
//MARK: - TableView Delegate Methods
    
    //to detect which row was selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //to delete data from persistent container using CoreData
        //First, remove NSManagedObject from context
        //context.delete(itemArray[indexPath.row])
        //Then, remove the item from itemArray
        //itemArray.remove(at: indexPath.row)
        
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
            
            //context is the viewContext of persistentContainer
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
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
        //to commit our context to permanent storage inside persistentContainer
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        //to reload tableView and show the new added data
        self.tableView.reloadData()
    }
    //this method has a default value '(Item.fetchRequest())' in case we call loadItems without giving it any parameters
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        //to decode and load up data in to-do list from permanent store through context
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - Search Bar Methods

//set viewController as the delegate for searchBar, so whenever there's changes in searchBar this is the class that's gonna to be informed
extension TodoListViewController: UISearchBarDelegate {
    //method will be triggered when the user press the searchBar button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //to read from context, create a request and declare its data type
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        //to query using coreData and specify what we get back from database
        //NSPredicate specifies how data should be fetched or filtered
        //cd makes the query insensitive for case and diacritic
        let predicate  = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //to sort the data that we get back from the database
        //add square brackets as sortDescriptors expects and array of NSSortDescriptor
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
       
    }
    //to go back to original list of all items when clear searchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            //to dismiss keyboard and cursor, when clearing searchBar
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}








