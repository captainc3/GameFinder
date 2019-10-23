import UIKit
import Firebase

struct Headline {
    var date : Date
    var title : String
    var location : String
    var skill : String
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

var headlines = [Headline]()

class ThirdViewController: UITableViewController {
    var count = 0

    var sections = [GroupedSection<Date, Headline>]()

    // MARK: - View Controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
        
        let logo = UIImage(named: "GameFinder3.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    func getData() {
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
                    }
                }
                headlines.append(Headline(date: eventDate, title: eventTitle, location: eventLoc, skill: eventSkill))
            }
            headlines.sort { $0.date < $1.date }
            self.sections = GroupedSection.group(rows: headlines, by: { firstDayOfMonth(date: $0.date) })
            self.sections.sort { lhs, rhs in lhs.sectionItem < rhs.sectionItem }
            self.tableView.reloadData()
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
        let section = self.sections[section]
        return section.rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let df = DateFormatter()
        df.dateFormat = "MMM d yyyy"

        let section = self.sections[indexPath.section]
        let headline = section.rows[indexPath.row]
        cell.textLabel?.text = headline.title + " | " + df.string(from: headline.date)
        cell.detailTextLabel?.text = headline.location
        tableView.backgroundView = UIImageView(image: UIImage(named: "IMG"))
        cell.backgroundColor = .clear

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath: NSIndexPath) {
        self.performSegue(withIdentifier: "ShowDetail", sender: self)
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            //passing variables to dest controller
        }
    }
}
