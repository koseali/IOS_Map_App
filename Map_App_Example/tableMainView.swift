//
//  tableMainView.swift
//  Map_App_Example
//
//  Created by Ali Köse on 7.11.2020.
//

import UIKit
import CoreData
class tableMainView: UIViewController, UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    var idArray = [UUID]()
    
    var choosenPlace = ""
    var choosenid : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButton))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData() 
    }
    @objc func addButton(){
        choosenPlace = ""
        performSegue(withIdentifier: "toViewController", sender: nil)}
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
    func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    if let  title = result.value(forKey: "title") as? String{
                        self.titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                }
                tableView.reloadData()
            }
        } catch  {
            print("Get Data Error")
        }
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenPlace = titleArray[indexPath.row]
        choosenid = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            let  destinationVC  = segue.destination as! ViewController
            destinationVC.selectPlace = choosenPlace
            destinationVC.selectid = choosenid
            
            
        }
    }
    
}
