//
//  Sender.swift
//  Pi-Controller
//
//  Created by Cody Meridith on 9/17/16.
//  Copyright © 2016 Cody Meridith. All rights reserved.
//

import Foundation
import UIKit

class PiStream: NSObject, StreamDelegate {
    
    var IP: String!
    var InputStream: InputStream!
    var OutputStream: OutputStream!
    
    override init()
    {
        
    }
    
    init(ip: String)
    {
        IP = ip;
    }
    
    func sendCode(code: String, length: Int)
    {
        let data = [UInt8](code.utf8)
        OutputStream.write(data, maxLength: length)
    }
    
    
    func openConnection() {
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, IP as CFString!, 7777, &readStream, &writeStream)
        
        InputStream = readStream!.takeRetainedValue()
        OutputStream = writeStream!.takeRetainedValue()
        
        InputStream.delegate = self
        OutputStream.delegate = self
        
        InputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        OutputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
        InputStream.open()
        OutputStream.open()
    }

    func closeConnection()
    {
        if InputStream != nil {
            InputStream.close()
        }
        if OutputStream != nil {
            OutputStream.close()
        }
    }
    
}
