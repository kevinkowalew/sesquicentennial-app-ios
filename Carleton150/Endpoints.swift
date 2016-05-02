//
//  Endpoints.swift
//  Carleton150

/// A class for managing the data service endpoints in the application.
final class Endpoints {
   
    /**
        The current server API URL.
     */
    static var hostServerURL: String = "https://carl150.carleton.edu"
    
    /**
        The current server API URL.
     */
    static var newHostServerURL: String = "https://go.carleton.edu"
   
    /**
        The current events endpoint in the API.
     */
    static var calendar: String {
        get {
            return self.hostServerURL + "/events"
        }
    }
    
    /**
        The current geofences endpoint in the API.
     */
    static var geofences: String {
        get {
            return self.hostServerURL + "/geofences"
        }
    }
    
    /**
        The current historical information endpoint in the API.
     */
    static var historicalInfo: String {
        get {
            return self.hostServerURL + "/info"
        }
    }
    
    /**
        The current quests endpoint in the API.
     */
    static var quests: String {
        get {
			return self.newHostServerURL + "/appquests"
        }
    }
}
