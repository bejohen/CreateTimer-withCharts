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
    @IBOutlet weak var timerProgress: CircularProgressBar!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    public var activities = [Activity]()
    
    public static var isRefreshed = false
    var seconds = 0
    var timer = Timer()
    var isTimerRunning = false
    var estimationInt = 60
    var spentInt = 0
    
    var hrs = 0
    var min = 0
    var sec = 0
    var milliSecs = 0
    var diffHrs = 0
    var diffMins = 0
    var diffSecs = 0
    var diffMilliSecs = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        //deleteAllData()
        let date = dateFormatter.date(from: "00:01")
        timePicker.date = date!
        // Do any additional setup after loading the view.

        //deleteAllData()
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground(noti:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(noti:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func pauseWhenBackground(noti: Notification) {
        self.timer.invalidate()
        let shared = UserDefaults.standard
        shared.set(Date(), forKey: "savedTime")
    }
    
    @objc func willEnterForeground(noti: Notification) {
        if let savedDate = UserDefaults.standard.object(forKey: "savedTime") as? Date {
            (diffHrs, diffMins, diffSecs) = TimerViewController.getTimeDifference(startDate: savedDate)
            
            self.refresh(hours: diffHrs, mins: diffMins, secs: diffSecs)
        }
    }
    
    static func getTimeDifference(startDate: Date) -> (Int, Int, Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: Date())
        return(components.hour!, components.minute!, components.second!)
    }
    
    func refresh (hours: Int, mins: Int, secs: Int) {
        let hrs = hours * 3600
        let minutes = mins * 60
        let s = secs
        seconds += hrs + minutes + s + 1
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimerViewController.updateTimer)), userInfo: nil, repeats: true)
        
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimerViewController.updateTimer)), userInfo: nil, repeats: true)
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
//        print("estimation : \(estimationInt)")
    }
    
    @objc func updateTimer() {
        seconds += 1     //This will decrement(count down)the seconds.
        timerLabel.text = timeString(time: TimeInterval(seconds)) //This will update the label.
        
        let progress = Double(seconds)/Double(estimationInt)
        if progress <= 1 {
            timerProgress.setProgress(to: progress, withAnimation: false)
        }
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if (!isTimerRunning) {
            runTimer()
            isTimerRunning = true
            startButton.setTitle("Pause", for: .normal)
            timerProgress.labelSize = 0
            timerProgress.safePercent = 80
            timerProgress.lineWidth = 20
        } else {
            let alert = UIAlertController(title: "Cancel timer", message: "What's the reason?", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "Input your reason here"
            })
            
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
                self.timer.invalidate()
                self.addActivity()
                self.refresh()
                TimerViewController.isRefreshed = true
                self.isTimerRunning = false
                self.startButton.setTitle("Resume", for: .normal)
            }))
            
            
            self.present(alert, animated: true)
            
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    //adding activity to coreData
    func addActivity() {
        let activity = Activity(entity: Activity.entity(), insertInto: context)
        let name = activities.count+1
        let hourFormat = DateFormatter()
        hourFormat.dateFormat = "HH:mm"
        let estimated = hourFormat.string(from: timePicker.date)
        
        activity.id = 1
        activity.name = "\(name)"
        activity.spendTime = "\(String(describing: timerLabel.text!))"
        activity.estimatedTime = "\(estimated)"
        activity.isCancelled = false
        activities.append(activity)
        appDelegate.saveContext()
    }
 
    func addActivity(cancel: Bool, reason: String) {
        let activity = Activity(entity: Activity.entity(), insertInto: context)
        let name = activities.count+1
        let hourFormat = DateFormatter()
        hourFormat.dateFormat = "HH:mm"
        let estimated = hourFormat.string(from: timePicker.date)
        activity.id = 1
        activity.name = "\(name)"
        activity.spendTime = "\(String(describing: timerLabel.text!))"
        activity.estimatedTime = "\(estimated)"
        activity.isCancelled = true
        activity.reason = reason
        activities.append(activity)
        appDelegate.saveContext()
    }
    
    private func refresh() {
        do {
            activities = try context.fetch(Activity.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func deleteAllData()
    {
        do {
            activities = try context.fetch(Activity.fetchRequest())
            for activity in activities
            {
                context.delete(activity)
            }
        } catch let error as NSError {
            print("Detele all data in activity error : \(error) \(error.userInfo)")
        }
    }
    
    func removeSavedDate() {
        if (UserDefaults.standard.object(forKey: "savedTime") as? Date) != nil {
            UserDefaults.standard.removeObject(forKey: "savedTime")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

