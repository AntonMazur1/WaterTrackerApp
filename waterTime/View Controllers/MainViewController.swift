//
//  ViewController.swift
//  waterTime
//
//  Created by Клоун on 25.04.2022.
//

import UIKit
import MBCircularProgressBar
import CoreData
import FBSDKLoginKit
import FirebaseAuth
import SystemConfiguration

class ViewController: UIViewController, SettingViewControllerDelegate {
    
    @IBOutlet var goalToDrink: UILabel!
    @IBOutlet var drank: UILabel!
    @IBOutlet var addWaterButton: UIButton!
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var currentSelect: Int?
    var result = 0
    
    let litres = [100, 200, 300, 400, 500]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        loadFromCoreData()
        checkForLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        progressBarSetup()
        loadFromCoreData()
    }
    
    //MARK: Add Litres
    @IBAction func addLitres(_ sender: UIButton) {
        guard let firstLitr = litres.first else {
            print("No first litr")
            return
        }
        result += currentSelect ?? firstLitr
        drank.text = String(result)
        
        progressBarSetup()
    }
    
    // MARK: Setup Protocols
    private func setup() {
        pickerView.delegate = self
        pickerView.dataSource = self
        addWaterButton.layer.cornerRadius = addWaterButton.frame.height / 2
    }
    
    // MARK: Progress Bar Setup
    private func progressBarSetup() {
        progressBar.maxValue = 100
        progressBar.value = CGFloat(Int(drank.text ?? "") ?? 0) * 100 / CGFloat(Int(goalToDrink.text ?? "") ?? 0)
        checkAddButton()
        saveData()
    }
    
    //MARK: Check Add Button For Available
    private func checkAddButton() {
        if progressBar.value >= progressBar.maxValue {
            progressBar.value = progressBar.maxValue
            drank.text = String(describing: Int(goalToDrink.text ?? "") ?? 0)
            result = Int(drank.text ?? "") ?? 0
            addWaterButton.isEnabled = false
        } else {
            addWaterButton.isEnabled = true
        }
    }
    
    //MARK: Check For Login With FaceBook
    func checkForLogin() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                self.present(loginVC, animated: true)
                return
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let VC = segue.destination as! SettingViewController
        VC.delegate = self
    }
    
    //MARK: Receive Data From Setting View Controller
    func fillLabel(text: String) {
        goalToDrink.text = text
        saveData()
    }
    
    // MARK: Core Data Settings
    private func saveData() {
        let entity = Water(context: context)
        entity.goalToDrink = goalToDrink.text ?? ""
        entity.drank = drank.text ?? ""
        entity.result = Int64(result)
        
        do {
            try context.save()
        } catch  {
            print("Something got wrong")
        }
    }
    
    private func loadFromCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Water")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            for result in result as! [NSManagedObject] {
                self.drank.text = result.value(forKey: "drank") as? String
                self.goalToDrink.text = result.value(forKey: "goalToDrink") as? String
                self.result = result.value(forKey: "result") as? Int ?? 0
            }
        } catch {
            print("Fail")
        }
    }
    
    //MARK: Delete Data From Core Data
    private func deleteAllData(){
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Water")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("Here was an error")
        }
    }
}

// MARK: Extension For View Controller
extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return litres.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?  {
        return String(litres[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentSelect = litres[row]
    }
}
