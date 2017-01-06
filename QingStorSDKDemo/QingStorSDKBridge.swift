//
//  QingStorSDKBridge.swift
//  QingStorSDKDemo
//
//  Created by Chris on 17/1/6.
//  Copyright © 2017年 Yunify. All rights reserved.
//

import Foundation
import QingStorSDK

public class QingStorSDKBridge: NSObject {
    public class func registerSDK() {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Config", ofType: "plist")!)
        try! Registry.registerFrom(plist: url)
    }
}
