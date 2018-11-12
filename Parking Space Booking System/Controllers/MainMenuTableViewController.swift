//
//  MainMenuTableViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 05/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

class MainMenuTableViewController: UITableViewController {

    var tickets = [ParkingTicket]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        loadParkingTickets(completion: {print(self.tickets.count)})
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: print(self.tickets.count)
            //add new ticket
            case 1: goTo(screenidentifier: "addticketVC")
            //location
            case 3: goTo(screenidentifier: "locationVC")
            default:
                print(indexPath.row)
            }
        } else {
            switch indexPath.row {
            //update profile
            case 0: goTo(screenidentifier: "updateVC")
            //instruction
            case 1: goTo(screenidentifier: "instructionVC")
            //contacts
            case 2 : contactsPressed()
            //logout
            case 3 : logoutPressed()
            default:
                print(indexPath.row)
            }
        }
        
    }
    
    private func loadParkingTickets(completion: @escaping () -> () ) {
        //var tickets = [ParkingTicket]()
        let user = Auth.auth().currentUser!
        let userRef = Database.database().reference()
        userRef.child("users").child(user.uid).child("tickets").observeSingleEvent(of: .value, with: { (snapshot) in
            for case let rest as DataSnapshot in snapshot.children {
                let value = rest.value as? NSDictionary
                let color = value?["color"] as? String
                let date = value?["date"] as? String
                let manufacturer = value?["manufacturer"] as? String
                let model = value?["model"] as? String
                let payment = value?["payment"] as? String
                let plate = value?["plate"] as? String
                let slotNumber = value?["slotNumber"] as? String
                let spotNumber = value?["spotNumber"] as? String
                let timing = value?["timing"] as? String
                let total = value?["total"] as? Double
                let userEmail = value?["userEmail"] as? String
                self.tickets.append(ParkingTicket(userEmail: userEmail!, carPlate: plate!, carManufacturer: manufacturer!, carModel: model!, carColor: color!, timing: timing!, date: date!, slotNumber: slotNumber!, spotNumber: spotNumber!, paymentMethod: payment!, total: total!))
            }
            completion()
            //print("inside function: \(tickets.count)")
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func goTo(screenidentifier: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: screenidentifier)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func logoutPressed() {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func contactsPressed() {
        let alert = UIAlertController(title: "Need help?", message: "Contact us:", preferredStyle: UIAlertController.Style.alert)
        //sending SMS
        alert.addAction(UIAlertAction(title: "SMS", style: .default, handler: sendSMS))
        //sending Email
        alert.addAction(UIAlertAction(title: "Email", style: .default, handler: sendEmail))
        //calling for help
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: makeCall))
        //cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func makeCall(alert: UIAlertAction!) {
        guard let number = URL(string: "tel://" + "1234567743") else { return }
        UIApplication.shared.open(number)
    }
    
    private func sendEmail(alert: UIAlertAction!) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["parking@lambton.com"])
        composeVC.setMessageBody("<p>My question is: </p>", isHTML: true)
        if MFMailComposeViewController.canSendMail() {
            self.present(composeVC, animated: true)
        }
    }
    
    private func sendSMS(alert: UIAlertAction!) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.recipients = ["13142026521"]
        composeVC.body = "My question is:"
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        }
    }

}

extension MainMenuTableViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK: Mail
extension MainMenuTableViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true)
    }
    
}
