//
//  UABuilder.swift
//  
//
//  Created by Edward Hinkle on 6/8/19.
//

import Foundation

//eg. Darwin/16.3.0
func DarwinVersion() -> String {
    var sysinfo = utsname()
    uname(&sysinfo)
    let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    return "Darwin/\(dv)"
}
//eg. CFNetwork/808.3
func CFNetworkVersion() -> String {
    let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
    let version = dictionary?["CFBundleShortVersionString"] as! String
    return "CFNetwork/\(version)"
}

//eg. iOS/10_1
func deviceVersion() -> String {
//    let currentDevice = UIDevice.current
//    return "\(currentDevice.systemName)/\(currentDevice.systemVersion)"
    // TODO: At some point, I need to find a way to get device info here
      return "Apple"
}

//eg. MyApp/1
func appNameAndVersion() -> String {
    let dictionary = Bundle.main.infoDictionary!
    let version = dictionary["CFBundleShortVersionString"]
    let name = dictionary["CFBundleName"]
    
    guard name != nil && version != nil else {
        return "IndieWebKit"
    }
    
    return "\(name ?? "")/\(version ?? "")"
}

func UAString() -> String {
    return "\(appNameAndVersion()) \(deviceVersion()) \(CFNetworkVersion()) \(DarwinVersion())"
}
