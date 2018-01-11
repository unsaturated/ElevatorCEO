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

#import "GameLayer.h"
#import "GCHelper.h"

@implementation GameLayer

-(id) init
{
	if( (self = [super init]) )
	{
		// Ensure all necessary sprites are loaded into the frame cache     
        //CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGRect winRect = [[GameController sharedInstance] gamingAreaRectForPlay:YES];
		CGSize winSize = winRect.size;
        
        
        // Switch graphics based upon the aspect ratio (iPhone 5)
        if([GameController sharedInstance].is16x9)
        {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"GameLayeri5.plist"];
        }
        else
        {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"GameLayer.plist"];
        }
        
        CGFloat wViewHeight = winSize.height;
		
		// Ensure all sprite animations are loaded into animation cache
		CCAnimation* wPoof = [CCAnimation animationWithSpriteSequence:@"poof%d.png" numFrames:5 delay:0.10f];
		[[CCAnimationCache sharedAnimationCache] addAnimation:wPoof name:@"Poof"];
		
		CCAnimation* wChest = [CCAnimation animationWithSpriteSequence:@"chest%d.png" numFrames:5 delay:0.20f];
		[[CCAnimationCache sharedAnimationCache] addAnimation:wChest name:@"Chest"];
        
        [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
		
        // Get from the preferences where the control side should be located (why have the player swap every time
        // if he prefers one side over the other?)
        CGPoint wPointForControl;
		CGPoint wPointForPlay;

		if([GameController sharedInstance].controlIsOnLeft)
		{
            // Control is at point zero, and play at point 80
			wPointForControl = ccp(winRect.origin.x, winRect.origin.y);
			wPointForPlay    = ccp(80, winRect.origin.y);
		}
		else 
		{
            // Play is at point zero (minus the gap), and control at point 240
			wPointForControl = ccp(240, winRect.origin.y);
			wPointForPlay    = ccp(-PLAY_AREA_MARGIN, winRect.origin.y);
		}
        
        // Add a black background for consistency - can't expect other layers to fill entire screen during 
        // scene transitions
        CCNode *wBg = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255) width:320 height:wViewHeight];
        [wBg setAnchorPoint:CGPointZero];
        wBg.position = CGPointZero;
        [self addChild:wBg z:0];
        
        // Startup music (control layer music icon checks status of music when loaded)
        [[AudioController sharedInstance] musicOn];
		
		// Add the play layer
		mPlayLayer = [GamePlayLayer node];
		mPlayLayer.position = wPointForPlay;
		[self addChild:mPlayLayer z:4];
		
		// Add the control layer
		mControlLayer = [GameControlLayer node];
        mControlLayer.position = wPointForControl;
		[self addChild:mControlLayer z:3];
        
        if([GameController sharedInstance].is16x9Device && ![GameController sharedInstance].adsRemovedByUser)
        {
            // Add a gradient background for the advertisements
            CGRect wAdRect = [GameController sharedInstance].adAreaRect;
            
            //CGRect wAdSpacerRect = CGRectOffset(winRect, 0.0f, -3.0f);
            //CCNode* wAdSpacer = [CCLayerColor layerWithColor:ccc4(200, 200, 200, 255)];
            
            //CCNode* wAdSpacer = [CCLayerGradient layerWithColor:ccc4(100, 100, 100, 225) fadingTo:ccc4(80, 80, 80, 225)];
            //[wAdSpacer setAnchorPoint:CGPointZero];
            //wAdSpacer.position = wAdSpacerRect.origin;
            //wAdSpacer.contentSize = CGSizeMake(HORIZONTAL_MAX_SIZE, 3.0f);
            //[self addChild:wAdSpacer z:2];
            
            //CCNode* wAdBg = [CCLayerGradient layerWithColor:ccc4(40, 40, 40, 255) fadingTo:ccc4(10, 10, 10, 255)];
            CCSprite* wAdBg = [CCSprite spriteWithSpriteFrameName:@"ad-over-bg.png"];
            [wAdBg setAnchorPoint:CGPointZero];
            wAdBg.position = wAdRect.origin;
            wAdBg.contentSize = wAdRect.size;
            [self addChild:wAdBg z:1];
        }
		
		// Let each object talk to the other
		[mControlLayer setGamePlayLayer:mPlayLayer];
		[mPlayLayer setGameControlLayer:mControlLayer];
		
        // Calculate the level characteristics then set it
		[[GameLevelMaker sharedInstance] calculateLevel:STARTING_LEVEL];
		[mControlLayer setLevel:STARTING_LEVEL];

		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

-(void) pause:(BOOL)pause
{
    if(pause)
    {
        [mPlayLayer showPauseMenu];
        [mControlLayer showPauseMenu];
    }
    else 
    {
        [mPlayLayer clearPauseMenu];
        [mControlLayer clearPauseMenu];
    }
}

@synthesize controlLayer = mControlLayer;

@synthesize playLayer = mPlayLayer;

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
    [mPlayLayer unscheduleAllSelectors];
    [mControlLayer unscheduleAllSelectors];
	[super dealloc];
}

-(void) onEnterTransitionDidFinish
{
    // Authenticate the player if not already
    [[GCHelper sharedGCHelper] authenticateLocalPlayer];
    
    BOOL adsRemoved = [GameController sharedInstance].adsRemovedByUser;
    BOOL is16x9 = [GameController sharedInstance].is16x9Device;
    BOOL adsLoaded = [GameController sharedInstance].adLoaded;
    
    if(is16x9 && adsLoaded && !adsRemoved)
    {
        [[GameController sharedInstance] animateAdBannerIntoView:YES];
    }
    
    [super onEnterTransitionDidFinish];
}

- (void) onExit
{
	// Not necessary for deallocation but the frame cache, no doubt, maintains
	// a reference to the sprites
    [[GameController sharedInstance] animateAdBannerIntoView:NO withDuration:0];
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    [CCAnimationCache purgeSharedAnimationCache];
	[super onExit];
}

@end
