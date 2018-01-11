/**
 * Elevator CEO is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *  
 * Elevator CEO is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *  
 * You should have received a copy of the GNU General Public License
 * along with Elevator CEO. If not, see 
 * https://github.com/unsaturated/ElevatorCEO/blob/master/LICENSE.
 */

#import "GCHelper.h"
#import "GameController.h"

@interface GCHelper () <GKGameCenterControllerDelegate>
{
    BOOL _gameCenterFeaturesEnabled;
    BOOL _displayingUnifiedController;
    UIViewController* _modalViewController;
    GKGameCenterViewController* _unifiedController;
}

@end

@implementation GCHelper

static GCHelper* mGCInstance = nil;

#pragma mark Singleton

+(id) sharedGCHelper
{
	if(mGCInstance)
		return mGCInstance;
	
    @synchronized(self)
    {
        if (mGCInstance == nil)
			mGCInstance = [[self alloc] init];
    }
    return mGCInstance;
}

#pragma mark Player Authentication

-(BOOL) gameCenterFeaturesEnabled
{
    return _gameCenterFeaturesEnabled;
}

-(void) authenticateLocalPlayer
{
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        [self setLastError:error];
        
        if(localPlayer.authenticated)
        {            
            _gameCenterFeaturesEnabled = YES;
        }
        else if(viewController)
        {
            if(_unifiedController)
            {
                [_unifiedController dismissViewControllerAnimated:YES completion:^
                {
                    _displayingUnifiedController = NO;
                    
                    BOOL wasPlaying = [GameController sharedInstance].isPlaying;
                    
                    if(wasPlaying)
                        [[GameController sharedInstance] pause:YES];
                    
                    [self presentModalViewController:viewController];
                }];
            }
            else
            {            
                BOOL wasPlaying = [GameController sharedInstance].isPlaying;
                
                if(wasPlaying)
                    [[GameController sharedInstance] pause:YES];
                
                [self presentModalViewController:viewController];
            }
        }
        else
        {
            _gameCenterFeaturesEnabled = NO;
            if(_unifiedController)
            {
                [_unifiedController removeFromParentViewController];
                _unifiedController.gameCenterDelegate = nil;
                _displayingUnifiedController = NO;
                _unifiedController = nil;
            }
        }
    };
}

-(void) submitScore:(int64_t)score category:(NSString*)category
{
    // 1: Check if Game Center features are enabled
    if(!_gameCenterFeaturesEnabled)
    {
        CCLOG(@"GCHelper - Cannot submit score because player is not authenticated!");
        return;
    }
    
    // 2: Create a GKScore object
    GKScore* gkScore = [[GKScore alloc] initWithLeaderboardIdentifier:category];
    
    // 3: Set the score value
    gkScore.value = score;
    
    NSArray* aryOfScores = [NSArray arrayWithObject:gkScore];
    
    // 4: Send the score to Game Center
    [GKScore reportScores:aryOfScores withCompletionHandler:^(NSError* error)
    {
        [self setLastError:error];
        BOOL success = (error == nil);
        
        if([_delegate respondsToSelector:@selector(onScoresSubmitted:)])
        {
            [_delegate onScoresSubmitted:success];
        }
    }];
}

#pragma mark Unified View Controller

-(void) displayUnifiedController
{
    if(!_gameCenterFeaturesEnabled)
    {
        CCLOG(@"GCHelper - Player not authenticated!");
        return;
    }
    
    if(_displayingUnifiedController)
    {
        CCLOG(@"Alreadying displaying Game Center unified controller");
        return;
    }
    
    // Create an instance of Game Center's unified controller
    GKGameCenterViewController* controller = [[[GKGameCenterViewController alloc] init] autorelease];
    
    if(controller)
    {
        controller.gameCenterDelegate = self;
        controller.viewState = GKGameCenterViewControllerStateLeaderboards;
        [self presentModalViewController:controller];
    }
}

-(void) gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    if(gameCenterViewController)
    {
        [gameCenterViewController dismissViewControllerAnimated:YES completion:^
         {
             [gameCenterViewController removeFromParentViewController];
             gameCenterViewController.gameCenterDelegate = nil;
             _displayingUnifiedController = NO;
             if(gameCenterViewController == _unifiedController)
                 _unifiedController = nil;
         }];
    }
}

#pragma mark Property Setters

-(void) setLastError:(NSError*)error
{
    _lastError = [error copy];
    if(_lastError)
    {
        NSLog(@"GameKitHelper ERROR: %@", [[_lastError userInfo] description]);
    }
}

#pragma mark UIViewController

-(void)presentModalViewController:(UIViewController*)vc
{
    [[GameController sharedInstance].rootViewController presentViewController:vc animated:YES completion:^
     {
         if([vc isKindOfClass:[GKGameCenterViewController class]])
         {
             _displayingUnifiedController = YES;
             _unifiedController = (GKGameCenterViewController*)vc;
         }
         else
         {
             _unifiedController = nil;
         }
     }];
}

@end