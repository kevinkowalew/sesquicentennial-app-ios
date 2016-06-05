//
//  QuestDataService.swift
//  Carleton150

import Foundation
import SwiftyJSON
import Alamofire

/// Data Service that contains relevant endpoints for the Quest module.
final class QuestDataService {
    
    /**
        Request quests for the game mode.
     
        - Parameters:
            - completion: function that will perform the behavior
                          that you want given a list with all the quests
                          from the server.
     */
    class func getQuests(completion: (success: Bool, result: [Quest]?) -> Void) {
        Alamofire.request(.POST, Endpoints.quests, parameters: nil, encoding: .JSON).responseJSON() {
            response in
            
            var quests: [Quest] = []
			
			if let result = response.result.value {
				let json = JSON(result)
				
				if let answer = json["content"].array {
					for i in 0 ..< answer.count {
						
						// create empty array of waypoints
						var wayPoints: [WayPoint] = []
						
						let points = answer[i]["waypoints"]
						
						// iterate through the waypoints from the server
						for i in 0 ..< points.count {
							let location = CLLocationCoordinate2D(
								latitude: points[i]["lat"].double!,
								longitude: points[i]["lng"].double!
							)
							
							var clue = [String: AnyObject]()
							var hint = [String: AnyObject]()
							var completion = [String: AnyObject]()
							
							clue["text"] = points[i]["clue"]["text"].string!
							hint["text"] = points[i]["hint"]["text"].string!
							
							if let compText = points[i]["completion"]["text"].string {
								completion["text"] = compText
							}
							
							wayPoints.append(
								WayPoint(location: location,
									radius: points[i]["rad"].double!,
									clue: clue,
									hint: hint,
									completion: completion
								)
							)
						}
						
						quests.append(
							Quest(
								wayPoints: wayPoints,
								name: answer[i]["name"].string!,
								description: answer[i]["desc"].string!,
								completionMessage: answer[i]["compMsg"].string!,
								creator: answer[i]["creator"].string!,
								image: answer[i]["image"].string!,
								difficulty: answer[i]["difficulty"].int!,
								audience: answer[i]["audience"].string!
							)
						)
						
					}
					completion(success: true, result: quests)
					
				} else {
					print("No results were found.")
					completion(success: false, result: nil)
				}
			} else {
				print("Connection to server failed.")
				completion(success: false, result: nil)
			}
		}
    }
}