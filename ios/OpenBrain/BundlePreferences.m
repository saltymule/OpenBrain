//
//  BundlePreferences.m
//  OpenBrain
//
//  Created by Daniel Mueller on 5/23/16.
//  Copyright © 2016 Daniel Mueller. All rights reserved.
//

#import "BundlePreferences.h"
@import React;

@interface BundlePreferences()<RCTBridgeModule>

@end

@implementation BundlePreferences

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setBundleAsset:(NSDictionary *)bundleAsset)
{
    NSString* relativeLocalPath = bundleAsset[@"relativeLocalPath"];
    
    if(relativeLocalPath != nil){
        [[NSUserDefaults standardUserDefaults] setObject:bundleAsset forKey:@"bundleAsset"];
    }
}

@end
