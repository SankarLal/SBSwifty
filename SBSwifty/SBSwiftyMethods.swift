//
//  SBSwiftyMethods.swift
//  SBSwifty
//
//  Created by support on 12/28/17.
//  Copyright © 2017 SANKARLAL. All rights reserved.
//

import Foundation


extension SBSwiftyService {
 
    class func getGeonames (_ url : String, completion : @escaping OnCompletion, failure : @escaping OnFailure) {
        doGenericGETCall(url,
                         completion: completion,
                         failure: failure)
        
    }

}

