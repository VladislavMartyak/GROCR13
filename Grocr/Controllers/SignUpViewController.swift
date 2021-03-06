import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    // MARK: Constants
    let signUpToList = "SignUpToList"
    let clientString = "Client"
    
    // MARK: Outlets
    @IBOutlet weak var textfieldName: UITextField!
    @IBOutlet weak var textfieldSurname: UITextField!
    @IBOutlet weak var textfieldEmail: UITextField!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var textfieldRole: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    
    @IBAction func registerUser() {

        Auth.auth().createUser(withEmail: self.textfieldEmail.text!, password: self.textfieldPassword.text!) { user, error in
            if error == nil {
                
                let userData = ["name": self.textfieldName.text,
                                "surname": self.textfieldSurname.text,
                                "role": self.textfieldRole.text]
                
                let ref = Database.database().reference()
                ref.child("Clients").child(Auth.auth().currentUser?.uid ?? "ERROR").setValue(userData)
                Auth.auth().signIn(withEmail: self.textfieldEmail.text!,
                                   password: self.textfieldPassword.text!)
                self.performSegue(withIdentifier: self.signUpToList, sender: nil)
            }
        }
        
        
        
    }
}
