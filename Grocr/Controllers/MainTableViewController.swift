import UIKit
import Firebase

class MainTableViewController: UITableViewController {
    
    // MARK: Constants
    let listToUsers = "ListToUsers"
    
    // MARK: Properties
    var items: [Appointment] = []
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    var userType: String = ""
    
    let ref = Database.database().reference(withPath: "Appointments")
    let usersRef = Database.database().reference(withPath: "Online")
    let clientsRef = Database.database().reference(withPath: "Clients")
    
    // MARK: Outlets
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        userCountBarButtonItem = UIBarButtonItem(title: "1",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        clientsRef.child(Auth.auth().currentUser?.uid ?? "h").child("role").observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? String{
                self.userType = value
            }
        })
        
        ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
            var newItems: [Appointment] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let appointmentItem = Appointment(snapshot: snapshot) {
                    if self.userType == "Client"{
                        if appointmentItem.addedByUser == Auth.auth().currentUser?.email{
                            newItems.append(appointmentItem)
                        }
                    } else if self.userType == "Worker" {
                        newItems.append(appointmentItem)
                    }
                }
            }
            
            self.items = newItems
            self.tableView.reloadData()
        })
        
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
            
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
        
        usersRef.observe(.value, with: { snapshot in
            if snapshot.exists() {
                self.userCountBarButtonItem?.title = snapshot.childrenCount.description
            } else {
                self.userCountBarButtonItem?.title = "0"
            }
        })
        
        clientsRef.child(Auth.auth().currentUser?.uid ?? "h").child("role").observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? String{
                if value == "Worker"{
                    self.labelStatus.text = "You have \(self.items.count) appointments today"
                }
            }
        })

        clientsRef.child(Auth.auth().currentUser?.uid ?? "h").child("name").observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? String{
                self.labelName.text = "Hi, \(value)"
            } else{
                self.labelName.text = "Hi, Client"
            }
        })
    }
    
    // MARK: UITableView Delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let groceryItem = items[indexPath.row]
        
        cell.textLabel?.text = groceryItem.appointmentType
        if userType == "Worker"{
            cell.detailTextLabel?.text = groceryItem.addedByUser
        } else {
            cell.detailTextLabel?.text = "Waiting to be confirmed"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let groceryItem = items[indexPath.row]
            groceryItem.ref?.removeValue()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
//        let groceryItem = items[indexPath.row]
//        let toggledCompletion = !groceryItem.completed
//        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
//        groceryItem.ref?.updateChildValues([
//            "completed": toggledCompletion
//        ])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
//        if !isCompleted {
//            cell.accessoryType = .none
//            cell.textLabel?.textColor = .black
//            cell.detailTextLabel?.textColor = .black
//        } else {
//            cell.accessoryType = .checkmark
//            cell.textLabel?.textColor = .gray
//            cell.detailTextLabel?.textColor = .gray
//        }
//    }
    
    // MARK: Add Item
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "New appointment",
                                      message: "What do you want?",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let textField = alert.textFields?.first,
                let text = textField.text else { return }
            
            
            let groceryItem = Appointment(name: text,
                                          addedByUser: self.user.email,
                                          completed: false)
            
            let groceryItemRef = self.ref.child(text.lowercased())
            
            groceryItemRef.setValue(groceryItem.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func userCountButtonDidTouch() {
        performSegue(withIdentifier: listToUsers, sender: nil)
    }
}
