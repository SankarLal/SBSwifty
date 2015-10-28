

import UIKit

// MARK: Declaring Blocks
typealias OnCompletion = (result: AnyObject?) -> Void
typealias OnSuccess = (result: AnyObject?) -> Void
typealias OnFailure = (result: AnyObject?) -> Void
typealias OnParseComplete = (result: AnyObject?) -> Void
typealias OnXMLParseComplete = (result: AnyObject?) -> Void

class SBSwifty: NSOperation, NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {
    // MARK: Declaring Variables

    var onSuccess:OnSuccess?
    var onFailure:OnFailure?
    var onParseComplete:OnParseComplete?
    var _headers:NSMutableDictionary?
    var receivedData:NSMutableData?

    var timeout:Double? = 60.0
    var usesCache: Bool?
    var responseCode:Int?
    
    // MARK: Assign Request Headers Method
    func setHeaders(headers:NSMutableDictionary) {
        _headers = headers
        
    }
        // MARK: JSON Get Method
    func executeJSONGet(url:NSString, success:OnSuccess, failure:OnFailure) {

        onSuccess = success;
        onFailure = failure;
        let set : NSCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        let uRL = NSURL (string: url.stringByAddingPercentEncodingWithAllowedCharacters(set)!)
        let  request:NSMutableURLRequest? = NSMutableURLRequest (URL: uRL!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: timeout!)
        request!.HTTPMethod = "GET"
        request!.addValue("application/json", forHTTPHeaderField:"Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.dataTaskWithRequest(request!)
        task.resume()

    }
    
    
    // MARK: JSON Post Method
    func executeJSONPost(url:NSString, requestBody:NSData?, success:OnSuccess, failure:OnFailure) {
        onSuccess = success;
        onFailure = failure;
        let set : NSCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        let uRL = NSURL (string: url.stringByAddingPercentEncodingWithAllowedCharacters(set)!)
        let  request:NSMutableURLRequest? = NSMutableURLRequest (URL: uRL!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: timeout!)
        request!.HTTPMethod = "POST"
        request!.HTTPBody = requestBody!
        request!.addValue("application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.dataTaskWithRequest(request!)
        task.resume()
        
    }
    
    // MARK: JSON Put Method
    func executeJSONPut(url:NSString,requestBody:NSData, success:OnSuccess, failure:OnFailure) {
        onSuccess = success;
        onFailure = failure;
        let set : NSCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        let uRL = NSURL (string: url.stringByAddingPercentEncodingWithAllowedCharacters(set)!)
        let  request:NSMutableURLRequest? = NSMutableURLRequest (URL: uRL!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: timeout!)
        request!.HTTPMethod = "PUT"
        request!.HTTPBody = requestBody
        request!.addValue("application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.dataTaskWithRequest(request!)
        task.resume()
        
    }

    // MARK: JSON Delete Method
    func executeJSONDelete(url:NSString, success:OnSuccess, failure:OnFailure) {
        onSuccess = success;
        onFailure = failure;
        let set : NSCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        let uRL = NSURL (string: url.stringByAddingPercentEncodingWithAllowedCharacters(set)!)
        let  request:NSMutableURLRequest? = NSMutableURLRequest (URL: uRL!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: timeout!)
        request!.HTTPMethod = "DELETE"
        request!.addValue("application/json", forHTTPHeaderField:"Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.dataTaskWithRequest(request!)
        task.resume()
        
        
    }

    // MARK: NSURLSession Data Delegate Function
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        receivedData = nil;
        receivedData = NSMutableData ()
        receivedData?.length = 0
        
        var httpResponse:NSHTTPURLResponse? = NSHTTPURLResponse()
        if let getHttpResponse = response as? NSHTTPURLResponse {
            httpResponse = getHttpResponse
        }
        assert(httpResponse!.isKindOfClass(NSHTTPURLResponse))
        responseCode = httpResponse?.statusCode

        if responseCode != 200 {
            
            let userInfo:NSMutableDictionary? = NSMutableDictionary()
            userInfo!.setValue(NSString(format: "Incorrect response code %ld received.",httpResponse!.statusCode), forKey: NSLocalizedDescriptionKey)
            userInfo!.setValue(dataTask.originalRequest?.URL?.absoluteString, forKey: NSURLErrorFailingURLStringErrorKey)
            let error:NSError? = NSError(domain: (dataTask.originalRequest?.URL?.host)!, code: -10001, userInfo: userInfo! as [NSObject : AnyObject])
            
            if let _ = onFailure {
                onFailure!(result:error)
                onFailure = nil
                
            }

        }

        completionHandler(.Allow)

    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        receivedData?.appendData(data)
        
    }
    
    // MARK: NSURLSession Task Delegate Function
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
       
        guard error == nil else {
            
            if let _ = onFailure {
                onFailure!(result:error)
                
            }
            onFailure = nil
            
            return
        }
        
        var responseString:NSString? = NSString (data: receivedData!, encoding: NSUTF8StringEncoding)!
        if responseString == nil {
            let tempString:NSString? = NSString (data: receivedData!, encoding: NSUTF8StringEncoding)!
            responseString = tempString;
            
        }
        
        if let _ = onSuccess {
            onSuccess!(result:responseString)
            onSuccess = nil
        }

    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        print("didReceiveChallenge")

    }
    
    
    // MARK: Parse JSON
    func parseJSON (data:NSString, parseComplete:OnParseComplete) {
        onParseComplete = parseComplete;
        var objectData:NSData? = data.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonDictionary: NSDictionary? = (try! NSJSONSerialization.JSONObjectWithData(objectData!, options:NSJSONReadingOptions.MutableContainers)) as? NSDictionary
        objectData = nil
        
        if let _ = onParseComplete {
            if jsonDictionary == nil {
                onParseComplete!(result:nil)
            } else {
             onParseComplete!(result:jsonDictionary)
            }
            onParseComplete = nil
            
        }
        
    }
   
}

