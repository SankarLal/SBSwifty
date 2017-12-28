

import UIKit

class SBSwiftyService: NSObject {

    class func doGenericGETCall(_ url : String,
                                 parameters: Parameters? = nil,
                                 headers: HTTPHeaders? = nil,
                                 completion : @escaping OnCompletion,
                                 failure : @escaping OnFailure) {
        
        makeSBSwiftyRequest(url,
                            method: .get,
                            parameters: parameters,
                            headers: headers,
                            completion: completion,
                            failure: failure)
    }
    
    class func doGenericPOSTCall(_ url : String,
                                 parameters: Parameters? = nil,
                                 headers: HTTPHeaders? = nil,
                                 completion : @escaping OnCompletion,
                                 failure : @escaping OnFailure) {
        
        makeSBSwiftyRequest(url,
                            method: .post,
                            parameters: parameters,
                            headers: headers,
                            completion: completion,
                            failure: failure)
    }

    class func doGenericPUTCall(_ url : String,
                                 parameters: Parameters? = nil,
                                 headers: HTTPHeaders? = nil,
                                 completion : @escaping OnCompletion,
                                 failure : @escaping OnFailure) {
        
        makeSBSwiftyRequest(url,
                            method: .put,
                            parameters: parameters,
                            headers: headers,
                            completion: completion,
                            failure: failure)
    }

    class func doGenericDELETECall(_ url : String,
                                 parameters: Parameters? = nil,
                                 headers: HTTPHeaders? = nil,
                                 completion : @escaping OnCompletion,
                                 failure : @escaping OnFailure) {
        
        makeSBSwiftyRequest(url,
                            method: .delete,
                            parameters: parameters,
                            headers: headers,
                            completion: completion,
                            failure: failure)
    }

   private class func makeSBSwiftyRequest(_ url : String,
                                   method: HTTPMethod = .get,
                                   parameters: Parameters? = nil,
                                   headers: HTTPHeaders? = nil,
                                   completion : @escaping OnCompletion,
                                   failure : @escaping OnFailure) {
        
        var completionBlock : OnCompletion? = completion
        let failureBlock : OnFailure? = failure

        let fetcher : SBSwifty = SBSwifty()

        fetcher.sbSwiftyRequest(url, method: method, parameters: parameters, headers: headers, success: { (result) in
            
            var data : AnyObject?
            fetcher.parseJSON(result as! String, parseComplete: { (result) -> Void in
                data = result as AnyObject
            })
            
            if completionBlock != nil{
                completionBlock!(data)
            }
            data = nil
            completionBlock = nil
            
            
        }) { (error) in
            if failureBlock != nil{
                failureBlock!(error)
            }
            completionBlock = nil
            
        }

    }


}
