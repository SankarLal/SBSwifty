

import UIKit

// MARK: Declaring Constant Variables
let SERVER_NAME :NSString   = "http://api.geonames.org/citiesJSON?north=44.1&south=-9.9&east=-22.4&west=55.2&lang=de&username=demo"


class SBSwiftyService: NSObject {

    class func doGenericGetCall (url:NSString, completion:OnCompletion, failure:OnFailure) {
        
        var completionBlock : OnCompletion? = completion
        let failureBlock : OnFailure? = failure
        let fetcher : SBSwifty = SBSwifty()
        
        fetcher.executeJSONGet(url, success: { (result) -> Void in
            
            var data:AnyObject?
            fetcher.parseJSON(result as! NSString, parseComplete: { (result) -> Void in
                data = result as? NSDictionary
            })
            
            if completionBlock != nil{
                completionBlock!(result: data)
            }
            data = nil
            completionBlock = nil
            
            
            }, failure: { (result) -> Void in
                if failureBlock != nil{
                    failureBlock!(result: result)
                }
                completionBlock = nil
                
        })
        
        
    }

    class func doGenericPostCall (param: NSString, url:NSString, completion:OnCompletion, failure:OnFailure) {
        
        var completionBlock : OnCompletion? = completion
        let failureBlock : OnFailure? = failure
        let fetcher : SBSwifty = SBSwifty()
        let requestBody: NSData = param.dataUsingEncoding(NSUTF8StringEncoding)!
        
        fetcher.executeJSONPost(url, requestBody: requestBody, success: { (result) -> Void in
            
            var data:AnyObject?
            fetcher.parseJSON(result as! NSString, parseComplete: { (result) -> Void in
                data = result as? NSDictionary
            })
            
            if completionBlock != nil{
                completionBlock!(result: data)
            }
            data = nil
            completionBlock = nil

            
            }, failure: { (result) -> Void in
                if failureBlock != nil{
                    failureBlock!(result: result)
                }
                completionBlock = nil
                
        })

    }
    
    class func doGenericPutCall (param: NSString, url:NSString, completion:OnCompletion, failure:OnFailure) {
        
        var completionBlock : OnCompletion? = completion
        let failureBlock : OnFailure? = failure
        let fetcher : SBSwifty = SBSwifty()
        let requestBody: NSData = param.dataUsingEncoding(NSUTF8StringEncoding)!
        
        fetcher.executeJSONPut(url, requestBody: requestBody, success: { (result) -> Void in
            
            var data:AnyObject?
            fetcher.parseJSON(result as! NSString, parseComplete: { (result) -> Void in
                data = result as? NSDictionary
            })
            
            if completionBlock != nil{
                completionBlock!(result: data)
            }
            data = nil
            completionBlock = nil
            
            
            }, failure: { (result) -> Void in
                if failureBlock != nil{
                    failureBlock!(result: result)
                }
                completionBlock = nil
                
        })
        
    }
    
    class func doGenericDeleteCall (url:NSString, completion:OnCompletion, failure:OnFailure) {
        
        var completionBlock : OnCompletion? = completion
        let failureBlock : OnFailure? = failure
        let fetcher : SBSwifty = SBSwifty()
        
        fetcher.executeJSONDelete(url, success: { (result) -> Void in
            
            var data:AnyObject?
            fetcher.parseJSON(result as! NSString, parseComplete: { (result) -> Void in
                data = result as? NSDictionary
            })
            
            if completionBlock != nil{
                completionBlock!(result: data)
            }
            data = nil
            completionBlock = nil
            
            
            }, failure: { (result) -> Void in
                if failureBlock != nil{
                    failureBlock!(result: result)
                }
                completionBlock = nil
                
        })
        
        
    }

    class func getGeonames (url:String, completion:OnCompletion, failure:OnFailure) {
        
        let uRL:NSString = NSString(format: "%@",
            url
        )
        
        doGenericGetCall(uRL,
            completion: completion,
            failure: failure)
        
    }
}
