//
//  ViewController.swift
//  waterTime
//
//  Created by Клоун on 25.04.2022.
//

import UIKit
import MBCircularProgressBar
import FBSDKLoginKit
import FirebaseAuth
import SystemConfiguration

class ViewController: UIViewController, SettingViewControllerDelegate {
    
    @IBOutlet var goalToDrink: UILabel!
    @IBOutlet var drank: UILabel!
    @IBOutlet var addWaterButton: UIButton!
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    private let litres = [100, 200, 300, 400, 500]
    private var currentSelect: Int?
    private var result = 0
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? SettingViewController else { return }
        vc.delegate = self
    }
    
    //MARK: Add Litres
    @IBAction func addLitres(_ sender: UIButton) {
        guard let firstLitr = litres.first else { return }
        result += currentSelect ?? firstLitr
        drank.text = String(result)
        progressBarSetup()
    }
    
    func fillLabel(text: String) {
        goalToDrink.text = text
        saveData()
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
        guard progressBar.value >= progressBar.maxValue else {
            addWaterButton.isEnabled = true
            return
        }
        
        progressBar.value = progressBar.maxValue
        drank.text = String(describing: Int(goalToDrink.text ?? "") ?? 0)
        result = Int(drank.text ?? "") ?? 0
        addWaterButton.isEnabled = false
    }
    
    //MARK: Check For Login With FaceBook
    private func checkForLogin() {
        AuthService.shared.checkForLogin { [weak self] loginVC in
            self?.present(loginVC, animated: true)
        }
    }
    
    // MARK: Core Data Settings
    private func saveData() {
        DataStorage.shared.saveData(goal: goalToDrink.text ?? "",
                                    drank: drank.text ?? "",
                                    result: result)
    }
    
    private func loadFromCoreData() {
        DataStorage.shared.loadFromCoreData { result in
            self.drank.text = result.value(forKey: "drank") as? String
            self.goalToDrink.text = result.value(forKey: "goalToDrink") as? String
            self.result = result.value(forKey: "result") as? Int ?? 0
        }
    }
    
    //MARK: Delete Data From Core Data
    private func deleteAllData(){
        DataStorage.shared.deleteAllData()
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
