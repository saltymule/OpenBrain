//
//  GameViewManager.m
//  OpenBrain
//
//  Created by Daniel Mueller on 4/19/16.
//  Copyright © 2016 Daniel Mueller. All rights reserved.
//

#import "GameViewManager.h"
#import "OpenBrain-Swift.h"

NSString* const GameViewDidComplete = @"GameViewDidComplete";

@interface GameViewManager()<GameViewDelegate>

@end

@implementation GameViewManager

RCT_EXPORT_MODULE();

RCT_EXPORT_VIEW_PROPERTY(data, NSDictionary)

-(UIView*)view{
    GameView* gameView = [[GameView alloc] init];
    gameView.gameViewDelegate = self;
    return gameView;
}

-(void)gameView:(GameView *)gameView didCompleteWithOptions:(NSDictionary<NSString *,id> *)options{
    //message RN
    [self.bridge.eventDispatcher sendAppEventWithName:GameViewDidComplete body:options];
}

-(NSDictionary<NSString *,id> *)constantsToExport{
    return @{
             @"gameViewDidComplete":GameViewDidComplete
             };
}

@end
