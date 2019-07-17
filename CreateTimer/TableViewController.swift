//
//  TableViewController.swift
//  CreateTimer
//
//  Created by Johanes Steven on 03/07/19.
//  Copyright © 2019 bejohen. All rights reserved.
//

import UIKit
import CoreData
import Charts

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var activityTableView: UITableView!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var chtChart: LineChartView!
    private var query = ""
    private var activities = [Activity]()
    private var allAccuracy = [Double]()
    private var fetchedRC: NSFetchedResultsController<Activity>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("accuracy total : \(allAccuracy.count)")
        getAccuracy()
        updateGraph()
    }
    var accuracy = 0.0
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityTableView.delegate = self
        activityTableView.dataSource = self
        getAccuracy()
        updateGraph()
        do{
            activities = try context.fetch(Activity.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        if TimerViewController.isRefreshed {
            self.activityTableView.reloadData()
            TimerViewController.isRefreshed = false
            getAccuracy()
            updateGraph()
            print("accuracy total : \(allAccuracy.count)")
        }
        //tableView(activityTableView, numberOfRowsInSection: activities.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("row \(activities.count)")
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(activities[indexPath.row].spendTime!) \(activities[indexPath.row].estimatedTime!):00"
        let dateFormat = DateFormatter()
        let spentFormat = DateFormatter()
        dateFormat.dateFormat = "HH:mm"
        spentFormat.dateFormat = "HH:mm:ss"
        
        let hourFormat = DateFormatter()
        hourFormat.dateFormat = "HH"
        let minFormat = DateFormatter()
        minFormat.dateFormat = "HH"
        
        let estimation = dateFormat.date(from: activities[indexPath.row].estimatedTime!)!
        let spent = spentFormat.date(from: activities[indexPath.row].spendTime!)!
        var hour = Int(activities[indexPath.row].estimatedTime!.substring(to: 2)) ?? 0
        var min = Int(getMin(getTime: activities[indexPath.row].estimatedTime!)) ?? 0
        let estimationInt = hour * 3600 + min * 60
        print(estimationInt)
        
        hour = Int(activities[indexPath.row].spendTime!.substring(to: 2)) ?? 0
        min = Int(getMin(getTime: activities[indexPath.row].spendTime!)) ?? 0
        let sec = Int(getSec(getTime: activities[indexPath.row].spendTime!)) ?? 0
        
        print("start time \(activities[indexPath.row].spendTime!), \(min), \(sec)")
        
        let spentInt = hour * 3600 + min * 60 + sec
        print(spentInt)
        if (Int(estimationInt) > Int(spentInt)) {
            accuracy = Double(spentInt) / Double(estimationInt)
        } else {
            accuracy = Double(estimationInt) / Double(spentInt)
        }
        
        accuracy = accuracy * 100
        //var y = Double(round(1000*accuracy)/1000)
        //y = y * 100
        
        print("spent int : \(Int(spentInt)) , estimated int : \(Int(estimationInt)), accuracy : \(accuracy)%")
        cell.detailTextLabel?.text = ("Accuracy : \(round(accuracy))%")

        //cell.detailTextLabel?.text = "\(spentFormat.string(from: comparison as Date))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let path = [indexPath]
            let act = activities[indexPath.row]
            context.delete(act)
            appDelegate.saveContext()
            allAccuracy.remove(at: indexPath.row)
            refresh()
            getAccuracy()
            updateGraph()
            tableView.deleteRows(at: path, with: .automatic)
        }
    }
    
    
    
    func getAccuracy() {
        allAccuracy.removeAll()
        for activity in activities {
            var accuracy = 0.0
            var hour = Int(activity.estimatedTime!.substring(to: 2)) ?? 0
            var min = Int(getMin(getTime: activity.estimatedTime!)) ?? 0
            let estimationInt = hour * 3600 + min * 60
            print(estimationInt)
            
            hour = Int(activity.spendTime!.substring(to: 2)) ?? 0
            min = Int(getMin(getTime: activity.spendTime!)) ?? 0
            let sec = Int(getSec(getTime: activity.spendTime!)) ?? 0
            let spentInt = hour * 3600 + min * 60 + sec
            
            if (Int(estimationInt) > Int(spentInt)) {
                accuracy = Double(spentInt) / Double(estimationInt)
            } else {
                accuracy = Double(estimationInt) / Double(spentInt)
            }
            accuracy = accuracy * 100
            allAccuracy.append(round(accuracy))
        }
        
    }
    
    func deleteAllData()
    {
        do
        {
            activities = try context.fetch(Activity.fetchRequest())
            for activity in activities
            {
                context.delete(activity)
            }
        } catch let error as NSError {
            print("Detele all data in activity error : \(error) \(error.userInfo)")
        }
    }
    
    func updateGraph(){
        var lineChartEntry = [ChartDataEntry]()
        
        for i in 0..<allAccuracy.count {
            let value = ChartDataEntry(x: Double(i), y: allAccuracy[i])
            
            lineChartEntry.append(value)
        }
        
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "Number")
        line1.colors = [NSUIColor.blue]
        
        let data = LineChartData()
        data.addDataSet(line1)
        
        chtChart.data = data
        chtChart.chartDescription?.text = "Your Performance Results"
    }
    
    private func refresh() {
        do{
            activities = try context.fetch(Activity.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func getMin(getTime: String) -> String {
        let index3 = getTime.index(getTime.startIndex, offsetBy: 3)
        let index5 = getTime.index(getTime.startIndex, offsetBy: 5)
        let min = getTime[index3..<index5]
        return String(min)
    }
    
    func getSec(getTime: String) -> String {
        let index6 = getTime.index(getTime.startIndex, offsetBy: 6)
        let sec = getTime[index6...]
        return String(sec)
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
//    func substring(with r: Range.Type) -> String {
//        let startIndex = index(from: r.startInde)
//        let endIndex = index(from: r.upperBound)
//        return substring(with: startIndex..<endIndex)
//    }
}
