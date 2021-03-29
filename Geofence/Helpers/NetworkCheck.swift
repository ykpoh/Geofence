//
//  NetworkCheck.swift
//  Geofence
//
//  Created by Poh  Yung Kien on 27/03/2021.
//

import Foundation
import Network

protocol NetworkCheckObserver: class {
    func statusDidChange(status: NWPath.Status)
}

protocol ReachabilityCheck {
    static func sharedInstance() -> ReachabilityCheck
    init()
    func addObserver(observer: NetworkCheckObserver)
    func removeObserver(observer: NetworkCheckObserver)
}

class NetworkCheck: ReachabilityCheck {
    struct NetworkChangeObservation {
        weak var observer: NetworkCheckObserver?
    }
    
    private var monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    private static let _sharedInstance = NetworkCheck()
    let queue = DispatchQueue(label: "setAndReadObserver", attributes: .concurrent)
    private var observations = [ObjectIdentifier: NetworkChangeObservation]()
    var currentStatus: NWPath.Status {
        get {
            return monitor.currentPath.status
        }
    }
    
    class func sharedInstance() -> ReachabilityCheck {
        return _sharedInstance
    }
    
    required init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let strongSelf = self else { return }
            strongSelf.queue.async {
                for (id, observations) in strongSelf.observations {
                    // If any observer is nil, remove it from the list of observers
                    guard let observer = observations.observer else {
                        strongSelf.observations.removeValue(forKey: id)
                        continue
                    }
                    
                    DispatchQueue.main.async(execute: {
                        observer.statusDidChange(status: path.status)
                    })
                }
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    func addObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        queue.async(flags: .barrier) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.observations[id] = NetworkChangeObservation(observer: observer)
        }
    }
    
    func removeObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        queue.async(flags: .barrier) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.observations.removeValue(forKey: id)
        }
    }
}
