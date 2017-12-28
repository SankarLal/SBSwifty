

import UIKit

public enum HTTPMethod : String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

public typealias HTTPHeaders = [String: String]
public typealias Parameters = [String: Any]

// MARK: Declaring Blocks
typealias OnCompletion = (_ result: AnyObject?) -> Void
typealias OnSuccess = (_ result: AnyObject?) -> Void
typealias OnFailure = (_ result: AnyObject?) -> Void
typealias OnParseComplete = (_ result: AnyObject?) -> Void

var timeout : Double = 60.0

class SBSwifty : Operation, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
    // MARK: Declaring Variables

    var onSuccess : OnSuccess?
    var onFailure : OnFailure?
    var onParseComplete : OnParseComplete?
    var _headers : [ String : AnyObject]?
    var receivedData : Data?

    var usesCache : Bool?
    var responseCode : Int?
    
    func sbSwiftyRequest(_ url : String,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        headers: HTTPHeaders? = nil,
                        success : @escaping OnSuccess,
                        failure : @escaping OnFailure) {
        
        onSuccess = success
        onFailure = failure
        sessionRequest(url,
                       method: method,
                       parameters: parameters,
                       headers: headers)
    }
    
   private func sessionRequest(_ url: String,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        headers: HTTPHeaders? = nil)  {
        
        var originalRequest: URLRequest = URLRequest(url: url, method: method, headers: headers, requestBody : parseData(parameters))
        
        if originalRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            originalRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: originalRequest)
        task.resume()
    }
    
    // MARK: NSURLSession Data Delegate Function
    func urlSession(_ session : URLSession, dataTask : URLSessionDataTask, didReceive response : URLResponse, completionHandler : @escaping (URLSession.ResponseDisposition) -> Void) {
        receivedData = nil;
        receivedData = Data()
        receivedData?.count = 0
        
        var httpResponse:HTTPURLResponse? = HTTPURLResponse()
        if let getHttpResponse = response as? HTTPURLResponse {
            httpResponse = getHttpResponse
        }
        assert(httpResponse!.isKind(of: HTTPURLResponse.self))
        responseCode = httpResponse?.statusCode

        if responseCode != 200 {
            let userInfo : [String : AnyObject]? = [
                NSLocalizedDescriptionKey : String.init(format: "Incorrect response code %ld received", (httpResponse?.statusCode)!) as AnyObject,
                NSURLErrorFailingURLStringErrorKey : dataTask.originalRequest?.url?.absoluteString as AnyObject
            ]
            let error : NSError? = NSError(domain: (dataTask.originalRequest?.url?.host)!, code: -10001, userInfo: userInfo! as [AnyHashable: Any] as? [String : Any])
            
            if let _ = onFailure {
                onFailure!(error)
                onFailure = nil
            }
        }
        completionHandler(.allow)
    }
    
    func urlSession(_ session : URLSession, dataTask : URLSessionDataTask, didReceive data : Data) {
        receivedData?.append(data)
    }
    
    // MARK: NSURLSession Task Delegate Function
    func urlSession(_ session : URLSession, task : URLSessionTask, didCompleteWithError error : Error?) {
        guard error == nil else {
            if let _ = onFailure {
                onFailure!(error as AnyObject?)
            }
            onFailure = nil
            return
        }
        
        var responseString : String? = String (data: receivedData! as Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        if responseString == nil {
            let tempString : String? = String (data: receivedData! as Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            responseString = tempString
        }
        
        if let _ = onSuccess {
            onSuccess!(responseString as AnyObject)
            onSuccess = nil
        }

    }
    
    func urlSession(_ session : URLSession, didReceive challenge : URLAuthenticationChallenge, completionHandler : @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
      
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential : URLCredential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential,credential)
        }
    }
    
    
    // MARK: Parse JSON
    func parseJSON (_ data : String, parseComplete : @escaping OnParseComplete) {
        onParseComplete = parseComplete
        var objectData : Data? = data.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        let jsonDictionary : [String : AnyObject]? = (try! JSONSerialization.jsonObject(with: objectData!, options:JSONSerialization.ReadingOptions.mutableContainers)) as? [String : AnyObject]
        objectData = nil

        print("jsonDictionary", jsonDictionary ?? "")
        
        if let _ = onParseComplete {
            if jsonDictionary == nil {
                onParseComplete!(nil)
            } else {
                onParseComplete!(jsonDictionary as AnyObject)
            }
            onParseComplete = nil
        }
    }
    
    func parseData(_ dictionary : [String: Any]?) -> Data? {
        
        guard let _ = dictionary else {
            return nil
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary!, options: .prettyPrinted)
            return jsonData
        }
        catch {
            print("ERROR IN DECODER")
            return nil
        }
    }
}

extension URLRequest {
    
    public init(url : String, method : HTTPMethod, headers : HTTPHeaders? = nil, requestBody: Data? = nil) {
        
        let uRL = URL(string: url.addingPercentEncoding())

        self.init(url: uRL!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
        httpMethod = method.rawValue
        
        if let headers = headers {
            for (headerField, headerValue) in headers {
                setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        
        if let _ = requestBody {
            self.httpBody = requestBody!
        }
        
    }
}

extension String {
    //MARK: Adding Percent Encoding
    func addingPercentEncoding() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}
