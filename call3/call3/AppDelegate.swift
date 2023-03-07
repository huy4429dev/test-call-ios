//
//  AppDelegate.swift
//  call
//
//  Created by Van Y Le on 07/11/2022.
//

import UIKit
import PushKit
import CallKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate, CXProviderDelegate {
    var provider: CXProvider? = nil;
    var callId: UUID? = nil;
    var callController = CXCallController()
    
    func providerDidReset(_ provider: CXProvider) {
        print("delete")
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        if let callId = self.callId
        {
            provider.reportCall(with: callId, endedAt: Date(), reason: .remoteEnded)
        }
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        if let callId = self.callId{
            provider.reportCall(with: callId, endedAt: Date(), reason: .unanswered)
        }
        print("end call")
        action.fulfill();
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("answer call")
        action.fulfill();
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
//        if type == PKPushType.voIP {
//            let token = pushCredentials.token.reduce("", {$0 + String(format: "%02X", $1) })
//            print(token)
//        }
    }
    
    func pushRegistry(
        _ registry: PKPushRegistry,
        didUpdatePushCredentials type: PKPushType
    ) {
        print("didInvalidatePushTokenFor")
    }
    
    func pushRegistry(
        _ registry: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for type: PKPushType,
        completion: @escaping () -> Void
    ) {
        print("didReceiveIncomingPushWith")
        
        if payload.dictionaryPayload["callEnded"] is Bool {
            let endCallAction = CXEndCallAction(call: GlobalVariables.callId);
            _ = CXTransaction(action: endCallAction)
            provider?.invalidate()
            provider = nil
            print("end call")
            return
        }
        
        if let uuidString = payload.dictionaryPayload["uuid"] as? String,
           let caller = payload.dictionaryPayload["caller"] as? String,
           let uuid = UUID(uuidString: uuidString) {
            print(uuid)
            initProvider();
            self.callId = uuid
            GlobalVariables.callId = uuid;
            
            if let provider = self.provider {
                let update = CXCallUpdate()
                update.hasVideo = true
                update.localizedCallerName = caller
                provider.reportNewIncomingCall(with: uuid, update: update) {error in}
            }
        }
        
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
            print("CALL END ACTION RUN")
           if let callEnded = userInfo["callEnded"] as? Bool,
              let callUUIDString = userInfo["callUUID"] as? String,
              let callUUID = UUID(uuidString: callUUIDString),
              callEnded {
               // End the call with the matching UUID
               let endCallAction = CXEndCallAction(call: callUUID)
               let transaction = CXTransaction(action: endCallAction)
               callController.request(transaction) { error in
                   if let error = error {
                       print("Failed to end call: \(error.localizedDescription)")
                   } else {
                       print("Call ended")
                   }
               }
           }
       }
    
    
    func initProvider(){
        if(self.provider != nil) {return}
        let config = CXProviderConfiguration()
        config.includesCallsInRecents = true
        config.supportsVideo = true
        config.supportedHandleTypes = [.generic]
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        self.provider = CXProvider(configuration: config)
        self.provider?.setDelegate(self, queue: DispatchQueue.main)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("run main")
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        voipRegistry.delegate = self
        initProvider();
     
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

class GlobalVariables {
    static var callId: UUID = UUID()
}

