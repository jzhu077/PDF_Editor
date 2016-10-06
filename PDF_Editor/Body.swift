//
//  main.swift
//  PDF_Editor
//
//  Created by Junyu Zhu on 10/4/16.
//  Copyright © 2016 Junyu Zhu. All rights reserved.
//

import Cocoa

public protocol BodyDelegate {
    func createRect(location:NSPoint)
}
public class Body: NSView{
    public var mouseClickLocation: NSPoint? = nil
    override public var intrinsicContentSize: NSSize{
        return NSSize(width: 800, height: 400)
    }
    
    override public func mouseDown (event: NSEvent) {
        NSLog("mouseLocation: \(event.locationInWindow)")
        mouseClickLocation = event.locationInWindow
        //NSLog("mouseDown: \(event.clickCount)")
    }
    
    override public func mouseDragged(event: NSEvent) {
        NSLog("mouseDragged: \(event.locationInWindow)")
    }
    override public func mouseUp(event: NSEvent) {
        //NSLog("mouseUp:")
    }
}
