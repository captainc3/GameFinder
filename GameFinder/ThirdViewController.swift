import UIKit
import Firebase
import GoogleMobileAds

struct Headline {
    var date : Date
    var title : String
    var location : String
    var skill : String
    var creator : String
    var category : String
}




private func firstDayOfMonth(date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: date)
    return calendar.date(from: components)!
}

private func parseDate(_ str : String) -> Date {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "MMM d yyyy"
    return dateFormat.date(from: str)!
}

private func parseDateString(_ date : Date) -> String {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "MMM d yyyy"
    return dateFormat.string(from: date)
}

var headlines = [Headline]()

class ThirdViewController: UITableViewController, UISearchBarDelegate {
    var count = 0
    var sections = [GroupedSection<Date, Headline>]()
    var filteredData = [Headline]()
    lazy var searchBar:UISearchBar = UISearchBar()

    // MARK: - View Controller lifecycle
    
    func LocalNotifications(Title: String, Body: String, Timeint: Int) {
        // Step 1: Ask for Permission
        let center =  UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) {(granted, error) in
            print("granted: \(granted)")
            
        }
        
        // Step 2: Create the notification content
        let content = UNMutableNotificationContent()
        content.title = Title
        content.body = Body
        
        // Step 3: Create the notification trigger
        let date = Date().addingTimeInterval(TimeInterval(Timeint))
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Step 4: Create the request
        
        let uuidString = UUID().uuidString
        
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // Step 5: Register the request
        center.add(request) { (error) in
            // Check the error parameter and handle any errors
        }
    }

    override func viewDidLoad() {
        LocalNotifications(Title: "Notification 1", Body: "Cheescake", Timeint: 5)
        LocalNotifications(Title: "Notification 2", Body: "Burger", Timeint: 10)
        super.viewDidLoad()
        self.getData()
        searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.placeholder = "Search title, skill, creator, location, or category"
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        let searchBarStyle = searchBar.value(forKey: "searchField") as? UITextField
        searchBarStyle?.clearButtonMode = .never
        searchBar.delegate = self
        self.tableView.tableHeaderView = searchBar
        let logo = UIImage(named: "GameFinder3.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        self.refreshControl?.addTarget(self, action: #selector(getData), for: UIControl.Event.valueChanged)
        self.tableView.reloadData()
    }
    
    var isFiltering: Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = headlines.filter { (headline: Headline) -> Bool in
          return (headline.title.lowercased().contains(searchText.lowercased()) ||
            headline.creator.lowercased().contains(searchText.lowercased()) ||
            headline.skill.lowercased().contains(searchText.lowercased()) ||
            headline.location.lowercased().contains(searchText.lowercased()) ||
            headline.category.lowercased().contains(searchText.lowercased()))
        }
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    @objc func getData() {
        headlines.removeAll()
        Database.database().reference().child("events").observeSingleEvent(of: .value, with: {
            snapshot in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let delimiter = " Created"
                let eventTitle = snap.key.components(separatedBy: delimiter)[0]
                var eventLoc = ""
                var eventSkill = ""
                var eventDate = Date()
                var eventDateString = ""
                var eventCreator = ""
                var eventCategory = ""
                let innerChildren = snap.value as? NSDictionary
                for x in innerChildren! {
                    if (x.key as! String == "Location of event") {
                        eventLoc = x.value as! String
                    }
                    if (x.key as! String == "Skill") {
                        eventSkill = x.value as! String
                    }
                    if (x.key as! String == "Time of event") {
                        let delimiter = " "
                        let dateString = Array((x.value as! String).components(separatedBy: delimiter).dropFirst().dropLast().dropLast())
                        eventDate = parseDate(dateString.joined(separator: " "))
                        eventDateString = dateString.joined(separator: " ")
                    }
                    if (x.key as! String == "Creator") {
                        eventCreator = x.value as! String
                    }
                    if (x.key as! String == "Category") {
                        eventCategory = x.value as! String
                    }
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d yyyy"
                let currentDateString = parseDateString(Date())
                if (formatter.date(from: eventDateString)?.compare(formatter.date(from: currentDateString)!) == .orderedSame) {
                    headlines.append(Headline(date: eventDate, title: eventTitle, location: eventLoc, skill: eventSkill,   creator: eventCreator, category: eventCategory))
                }
                if (formatter.date(from: eventDateString)?.compare(formatter.date(from: currentDateString)!) == .orderedDescending) {
                    headlines.append(Headline(date: eventDate, title: eventTitle, location: eventLoc, skill: eventSkill,   creator: eventCreator, category: eventCategory))
                }
            }
            headlines.sort { $0.date < $1.date }
            self.filteredData = headlines
            self.sections = GroupedSection.group(rows: headlines, by: { firstDayOfMonth(date: $0.date) })
            self.sections.sort { lhs, rhs in lhs.sectionItem < rhs.sectionItem }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.sections[section]
        let date = section.sectionItem
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: date)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredData.count
        }
        let section = self.sections[section]
        return section.rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let df = DateFormatter()
        df.dateFormat = "E, MM/d/yy"

        let section = self.sections[indexPath.section]
        var headline = section.rows[indexPath.row]
        if isFiltering {
            headline = filteredData[indexPath.row]
        } else {
            headline = section.rows[indexPath.row]
        }
        cell.textLabel?.text = headline.title + " | " + df.string(from: headline.date)

        cell.detailTextLabel?.text = headline.location
        tableView.backgroundView = UIImageView(image: UIImage(named: "IMG"))
        cell.backgroundColor = .clear
        
        cell.textLabel?.textColor = UIColor.white

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let vc = segue.destination as! EventController
                if isFiltering {
                    vc.cellDetails = filteredData[indexPath.row].title + " Created by: " + filteredData[indexPath.row].creator
                } else {
                    vc.cellDetails = headlines[indexPath.row].title + " Created by: " + headlines[indexPath.row].creator
                }
            }
        }
    }
}
