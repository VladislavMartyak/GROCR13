import Foundation
import Firebase

struct Appointment {
    
    let ref: DatabaseReference?
    let key: String
    let appointmentType: String
    
    let addedByUser: String
    var completed: Bool
    
    init(name: String, addedByUser: String, completed: Bool, key: String = "") {
        self.ref = nil
        self.key = key
        self.appointmentType = name
        self.addedByUser = addedByUser
        self.completed = completed
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String,
            let addedByUser = value["addedByUser"] as? String,
            let completed = value["completed"] as? Bool else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.appointmentType = name
        self.addedByUser = addedByUser
        self.completed = completed
    }
    
    func toAnyObject() -> Any {
        return [
            "name": appointmentType,
            "addedByUser": addedByUser,
            "completed": completed
        ]
    }
}
