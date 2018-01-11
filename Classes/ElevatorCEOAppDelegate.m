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

#import "cocos2d.h"
#import "ElevatorCEOAppDelegate.h"
#import "MainMenuLayer.h"
#import "GameController.h"
#import "GCHelper.h"
#import "RootViewController.h"

@implementation ElevatorCEOAppDelegate

@synthesize window;
@synthesize adView;

-(RootViewController*) rootViewController
{
    return viewController;
}

+ (void) initialize
{
	if(self == [ElevatorCEOAppDelegate class]) 
	{
        [[GameController sharedInstance] setDefaultAppSettings];
    }
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *wDirector = [CCDirector sharedDirector];
    
    // Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	
	// Turn OFF multiple touches
	EAGLView *view = [wDirector openGLView];
	[view setMultipleTouchEnabled:NO];
	
	// cocos2d will inherit these values
	[view setUserInteractionEnabled:YES];
    
    // Use Retina
    [wDirector enableRetinaDisplay:YES];
    
    // make the OpenGLView a child of the view controller
	[viewController setView:view];
    
    // Is this right??
    [self.window setRootViewController:viewController];
	
	[[GameController sharedInstance] restoreAppSettings];
    
    // Only create the iAd object if the user hasn't removed them
    if(![GameController sharedInstance].adsRemovedByUser && [GameController sharedInstance].is16x9Device)
    {
        // Get interstitial ads queued up and display them manually
        [UIViewController prepareInterstitialAds];
        viewController.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual;
        
        // Create the view for iAd
        self.adView = [[[ADBannerView alloc] initWithAdType:ADAdTypeBanner] autorelease];
        self.adView.delegate = [GameController sharedInstance];
        [viewController.view addSubview:self.adView];
        [viewController.view sendSubviewToBack:self.adView];
        
        // Temp vars for iAd positioning
        CGSize vcSize = CGSizeMake(viewController.view.frame.size.width, viewController.view.frame.size.height);
        CGSize adSize = CGSizeMake(self.adView.frame.size.width, self.adView.frame.size.height);
        
        // Position iAd on bottom of screen
        CGRect adFrame = adView.frame;
        
        // Offscreen initialization
        //adFrame.origin.y = vcSize.height + adSize.height;
        //adFrame.origin.x = (vcSize.width / 2.0f) - (adSize.width / 2.0f);
        
        // Onscreen initialization
        //adFrame.origin.y = vcSize.height - adSize.height;
        //adFrame.origin.x = (vcSize.width / 2.0f) - (adSize.width / 2.0f);
        
        // Offscreen initialization
        adFrame.origin.y = vcSize.height + adSize.height;
        adFrame.origin.x = (vcSize.width / 2.0f) - (adSize.width / 2.0f);
        
        adView.frame = adFrame;
    }

#ifdef RELEASE
	[[GameController sharedInstance] debug:NO];
#else
    [[GameController sharedInstance] debug:YES];
#endif
    
	[wDirector runWithScene:[MainMenuLayer node]];
}

- (void)applicationWillResignActive:(UIApplication *)application 
{
    GameController *con = [GameController sharedInstance];
    [con pause:YES];
    [con saveAppSettings];
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
    // Pause depends upon the game state. If not playing then just pause 
    // and resume the director when requested. 
    // However, if playing, let the user decide.
    if(![GameController sharedInstance].isPlaying)
    {
        [[GameController sharedInstance] pause:NO];
    }
    
    // We have no idea how long it has been since the player authenticated,
    // so if the Game Center features are enabled, ensure that state is still
    // valid by re-authenticating
    if([GameController sharedInstance].gameCenterWasPreviouslyAuthenticated)
    {
        CCLOG(@"Re-authenticating player because that was the previously known state");
        GCHelper* gcHelper = [GCHelper sharedGCHelper];
        [gcHelper authenticateLocalPlayer];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application 
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application 
{
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	[[GameController sharedInstance] saveAppSettings];
	[[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application 
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

-(void)animateAdBannerIntoView:(BOOL)intoView withDuration:(double)duration
{
    if(self.adView == nil)
        return;
    
    CGSize vcSize = CGSizeMake(viewController.view.frame.size.width, viewController.view.frame.size.height);
    CGSize adSize = CGSizeMake(self.adView.frame.size.width, self.adView.frame.size.height);
    
    if(intoView)
    {
        [UIView animateWithDuration:duration
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             CGRect adFrame = self.adView.frame;
                             adFrame.origin.y = vcSize.height - adSize.height;
                             adFrame.origin.x = (vcSize.width / 2.0f) - (adSize.width / 2.0f);
                             self.adView.frame = adFrame;
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Ad banner UIView animation into view is complete!");
                         }];
    }
    else
    {
        [UIView animateWithDuration:duration
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             CGRect adFrame = self.adView.frame;
                             adFrame.origin.y = vcSize.height + adSize.height;
                             adFrame.origin.x = (vcSize.width / 2.0f) - (adSize.width / 2.0f);
                             self.adView.frame = adFrame;
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Ad banner UIView animation out of view is complete!");
                         }];
    }
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
