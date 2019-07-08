//
//  ViewController.swift
//  CreateTimer
//
//  Created by Johanes Steven on 03/07/19.
//  Copyright © 2019 bejohen. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timeEstimation: UILabel!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    public var activities = [Activity]()
    
    public static var isRefreshed = false
    var seconds = 0
    var timer = Timer()
    var isTimerRunning = false
    var estimationInt = 0
    var spentInt = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        
        let date = dateFormatter.date(from: "00:01")
        
        timePicker.date = date!
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do{
            activities = try context.fetch(Activity.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(TimerViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        let hourFormat = DateFormatter()
        hourFormat.dateFormat = "HH"
        let minFormat = DateFormatter()
        minFormat.dateFormat = "mm"
        timeEstimation.text = "\(hourFormat.string(from: timePicker.date)) H \(minFormat.string(from: timePicker.date)) m"
        let hour = Int(hourFormat.string(from: timePicker.date)) ?? 0
        let min = Int(minFormat.string(from: timePicker.date)) ?? 1
        estimationInt = (hour * 3600) + (min * 60)
        print("estimation : \(estimationInt)")
    }
    @objc func updateTimer() {
        seconds += 1     //This will decrement(count down)the seconds.
        timerLabel.text = timeString(time: TimeInterval(seconds)) //This will update the label.
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if (!isTimerRunning) {
            runTimer()
            isTimerRunning = true
            startButton.setTitle("Pause", for: .normal)
        } else {
            timer.invalidate()
            addActivity()
            refresh()
            TimerViewController.isRefreshed = true
            isTimerRunning = false
            startButton.setTitle("Resume", for: .normal)
            
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    //adding activity to coreData
    @IBAction func addActivity() {
        let activity = Activity(entity: Activity.entity(), insertInto: context)
        let name = activities.count+1
        let hourFormat = DateFormatter()
        hourFormat.dateFormat = "HH:mm"
        let estimated = hourFormat.string(from: timePicker.date)
        activity.id = 1
        activity.name = "\(name)"
        activity.startTime = "\(String(describing: timerLabel.text!))"
        activity.finishTime = "10:50"
        activity.estimatedTime = "\(estimated)"
        activities.append(activity)
        appDelegate.saveContext()
    }
    
    private func refresh() {
        do{
            activities = try context.fetch(Activity.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
}

