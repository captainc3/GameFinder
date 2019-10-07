//
//  FourthViewController.swift
//  GameFinder
//
//  Created by Steven Corrales on 10/2/19.
//  Copyright © 2019 Steven Corrales. All rights reserved.
//

import UIKit
import JTAppleCalendar

class FourthViewController: UIViewController {
    @IBOutlet var calendarView: JTACMonthView!
    var calendarDataSource: [String:String] = [:]
    var formatter = DateFormatter()
    var selectedDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        calendarView.scrollDirection = .vertical
        calendarView.scrollingMode   = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
        // Do any additional setup after loading the view.

        populateDataSource()
    }
    
    @objc func buttonClicked(sender: UIButton!) {
        print(sender.currentTitle!)
        
    }
    
    func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        cell.layer.borderWidth = 0.2
        cell.layer.borderColor = UIColor.black.cgColor
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellEvents(cell: cell, cellState: cellState)
        cell.dateButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        cell.dateButton.setTitle(cellState.date.description, for: UIControl.State.normal)
        cell.dateButton.setTitleColor(UIColor.clear, for: UIControl.State.normal)
    }

    
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.black
        } else {
            cell.dateLabel.textColor = UIColor.gray
        }
    }
    
    func populateDataSource() {
        // You can get the data from a server.
        // Then convert that data into a form that can be used by the calendar.
        calendarDataSource = [
            "07-Oct-2019": "SomeData",
            "15-Oct-2019": "SomeMoreData",
            "21-Oct-2019": "onlyData",
        ]
        // update the calendar
        calendarView.reloadData()
    }
    
    func handleCellEvents(cell: DateCell, cellState: CellState) {
        let dateString = formatter.string(from: cellState.date)
        if calendarDataSource[dateString] != nil {
            cell.layer.backgroundColor = UIColor.lightGray.cgColor
            cell.dateButton.isHidden = false
        } else {
            cell.layer.backgroundColor = UIColor(displayP3Red: 211.0, green: 211.0, blue: 211.0, alpha: 1.0).cgColor
            cell.dateButton.isHidden = true
        }
    }

    func handleCellSelection(view: DateCell, cellState: CellState) {
            if cellState.isSelected {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "econtroller") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
                print(cellState.date)
                view.layer.backgroundColor = UIColor.red.cgColor
            } else {
                view.layer.backgroundColor = UIColor.white.cgColor
            }
    }

    var iii: Date?
}

extension FourthViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        formatter.dateFormat = "dd-MMM-yyyy"

        let startDate = formatter.date(from: "01-aug-2019")!
        let endDate = formatter.date(from: "01-aug-2020")!
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
    
}

extension FourthViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
//        handleCellSelection(cell: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? DateCell else { return }
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState) {
//        handleCellSelection(view: cell, cellState: cellState)
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState) {
//        handleCellSelection(view: cell, cellState: cellState)
        configureCell(view: cell, cellState: cellState)
    }
    
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let formatter = DateFormatter()  // Declare this outside, to avoid instancing this heavy class multiple times.
        formatter.dateFormat = "MMM yyyy"
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthTitle.text = formatter.string(from: range.start)
        return header
    }

    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        calendarView.viewWillTransition(to: size, with: coordinator, anchorDate: iii)
    }
}
