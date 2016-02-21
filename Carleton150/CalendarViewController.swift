//
//  CalendarViewController.swift
//  Carleton150

import Foundation
import SwiftOverlays

class CalendarViewController: UICollectionViewController {
   
    var calendar: [Dictionary<String, AnyObject?>] = []
    var filteredCalendar: [Dictionary<String, AnyObject?>] = []
    var cells: [CalendarCell] = []
    var eventImages: [UIImage] = []
    var tableLimit : Int!
    var parentView: CalendarFilterViewController!
   
    
    /**
        Upon load of this view, load the calendar and adjust the 
        collection cells for the calendar.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector: "actOnFilterUpdate:", name: "carleton150.filterUpdate", object: nil)
       
        // set the parent view
        self.calendar = self.parentView.calendar
        self.filteredCalendar = self.parentView.calendar
        
        // set the current table limit
        self.tableLimit = self.filteredCalendar.count

        // set the view's background colors
        view.backgroundColor = UIColor(red: 252, green: 212, blue: 80, alpha: 1.0)
        collectionView!.backgroundColor = UIColor(red: 224, green: 224, blue: 224, alpha: 1.0)
        
        // set the deceleration rate for the event cell snap
        collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "showCalendarDetail") {
			let detailViewController = (segue.destinationViewController as! CalendarDetailView)
			detailViewController.parentView = self
            detailViewController.setData(sender as! CalendarCell)
		}
    }
    
    func actOnFilterUpdate(notification: NSNotification) {
        if let date: NSDate = notification.userInfo!["date"] as? NSDate {
            self.filteredCalendar = calendar.filter() {
                event in
                return (event["startTime"] as! NSDate).isGreaterThanDate(date)
            }
            self.collectionView!.reloadData()
            self.collectionView!.setContentOffset(CGPoint(x: 0,y: 0), animated: false)
        }
    }
    
    /**
        Gets the image backgrounds for the calendar.
     
        - Returns: A list of UIImage backgrounds to place in the collection view.
     */
    func getEventImages() -> [UIImage] {
        for i in 1 ..< 11 {
            let eventImage = UIImage(named: "Event-" + String(i))
            if let eventImage = eventImage {
              eventImages.append(eventImage)
            }
        }
        return eventImages
    }
    
    /**
        Determines the number of sections in the calendar collection view.
     
        - Parameters:
            - collectionView: The collection view being used for the calendar.
     */
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    /**
        Determines the number of cells in the calendar collection view.
     
        - Parameters:
            - collectionView:         The collection view being used for the calendar.
     
            - numberOfItemsInSection: The number of items in the calendar.
     */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendar.count
    }
    
    /**
        Animates a section of the calendar to focus at the top of the page on tap.
     
        - Parameters:
            - collectionView: The collection view being used for the calendar.
     
            - indexPath:      The index of the cell that was clicked.
     */
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let layout = collectionViewLayout as! CalendarLayout
        let offset = layout.dragOffset * CGFloat(indexPath.item)
        if collectionView.contentOffset.y != offset {
            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        }
    }
    
    /**
        Fills each section of the calendar with data as they are loaded into the view.
     
        - Parameters:
            - collectionView: The collection view being used for the calendar.
     
            - indexPath:      The index of the current cell.
     
        - Returns: A built calendar cell.
     */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CalendarCell", forIndexPath: indexPath) as! CalendarCell
        let images = getEventImages()
        let eventText = filteredCalendar[indexPath.item]["title"]
        cell.eventTitle.text = eventText as? String
        cell.currentImage = images[indexPath.item % 10]
        cell.locationLabel.text = filteredCalendar[indexPath.item]["location"]! as? String
        let date: String
        if let result: NSDate = filteredCalendar[indexPath.item]["startTime"] as? NSDate {
            date = parseDate(result)
        } else {
            date = "No Time Available"
        }
        cell.timeLabel.text = date
        cell.eventDescription = filteredCalendar[indexPath.item]["description"]! as? String
        return cell
    }
    
    private func parseDate(date: NSDate) -> String {
        let outFormatter = NSDateFormatter()
        outFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        outFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return outFormatter.stringFromDate(date)
    }
   
    /**
        In case of a bad connection, handles it and informs the user.
    
        - Parameters: 
            - limit: The limit on the number of events in case the
                     user wants to try requesting for information again. 
     
            - date:  The earliest date from which to get data in case the 
                     user wants to try again.
     */
    func badConnection(limit: Int, date: NSDate) {
        let alert = UIAlertController(title: "Bad Connection", message: "You seemed to have trouble connecting to our server. Try again?", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction1 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) {
            (UIAlertAction) -> Void in
            // do nothing for now.
        }
        let alertAction2 = UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default) {
            (UIAlertAction) -> Void in
            // TODO: Fix how this works.
        }
        alert.addAction(alertAction1)
        alert.addAction(alertAction2)
        self.presentViewController(alert, animated: true) { () -> Void in }
    }
}

extension NSDate {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        var isGreater = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        var isLess = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        var isEqualTo = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        
        return isEqualTo
    }
}

