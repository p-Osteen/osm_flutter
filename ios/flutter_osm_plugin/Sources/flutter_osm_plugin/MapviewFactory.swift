//
//  MapViewFactory.swift
//  Runner
//
//  Created by Dali on 6/12/20.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import Flutter

public class MapviewFactory : NSObject, FlutterPlatformViewFactory {
    let messenger : FlutterBinaryMessenger
    let defaultPinPath:String?
    init(messenger:FlutterBinaryMessenger,defaultPin:String?) {
        self.messenger = messenger
        self.defaultPinPath = defaultPin
    }
    
    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
       let channel = FlutterMethodChannel(
            name: "plugins.dali.hamza/osmview_"+String(viewId),
            binaryMessenger: self.messenger
        )
        return MapCoreOSMView(frame, viewId: viewId, channel: channel, args: args, defaultPin: defaultPinPath)
        //return MyMapView(frame, viewId: viewId, channel: channel, args: args,dynamicOSM: dynamicOSMPath,defaultPin: defaultPinPath)
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
