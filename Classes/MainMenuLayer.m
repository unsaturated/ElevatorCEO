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
#import "MainMenuLayer.h"
#import "OptionsMenuLayer.h"
#import "ScoreMenuLayer.h"
#import "GameController.h"
#import "AudioController.h"
#import "MainMenuLargeElevator.h"

@implementation MainMenuLayer

#pragma mark Overriding Methods ___________________________

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init] )) 
	{
        // The game caanot be paused if the main menu is displayed
        [[GameController sharedInstance] pause:NO];
        
        CGRect winRect = [GameController sharedInstance].gamingAreaRect;
		CGSize winSize = winRect.size;
		int wHalfWidth = winSize.width / 2;
		
        // Switch graphics based upon the aspect ratio (iPhone 5)
        if([GameController sharedInstance].is16x9Device)
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MainMenui5.plist"];
        else
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MainMenu.plist"];
        
        // Background sky, streets, and ground
		CCSprite *wBackground = [CCSprite spriteWithSpriteFrameName:@"intro-bg.png"];
        [wBackground setAnchorPoint:winRect.origin];
		wBackground.position = winRect.origin;
		[self addChild: wBackground z:0];
        
        
		// Free banner (only displayed on free versions)
#ifdef FREE_VERSION
		CCSprite *wFree = [CCSprite spriteWithSpriteFrameName:@"free-banner.png"];
		[wFree setAnchorPoint:CGPointMake(1.0f, 1.0f)];
		wFree.position = ccp(winSize.width + 10.0f, winSize.height - wFree.contentSize.height);
		[self addChild: wFree z:21];
		
        CCLabelBMFont *wFreeFont = [[GameController sharedInstance] makeFontFrom:NSLocalizedString(@"FREE_BANNER", nil) withEnum:kDroidSansBold28White];
        wFreeFont.scale = 0.7f;
		wFreeFont.position = ccp(wFree.contentSize.width / 2.0f, wFree.contentSize.height / 2.0f + 1.0f);
		[wFree addChild:wFreeFont z:1];
#endif
		
		// Play menu item
		CCSprite *wPlayOnItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-on.png"];
		CCSprite *wPlayOffItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-off.png"];
		
		mPlayMenuItem = [CCMenuItemImage
						 itemFromNormalSprite:wPlayOffItem 
						 selectedSprite:wPlayOnItem 
						 target:self 
						 selector:@selector(menuButtonTapped:)];
		
		// Scores menu item
		CCSprite *wScoresOnItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-on.png"];
		CCSprite *wScoresOffItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-off.png"];

		
		mScoresMenuItem = [CCMenuItemImage 
						   itemFromNormalSprite:wScoresOffItem 
						   selectedSprite:wScoresOnItem 
						   target:self 
						   selector:@selector(menuButtonTapped:)];
		
		// More menu item
		CCSprite *wMoreOnItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-on.png"];
		CCSprite *wMoreOffItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-off.png"];

		
		
		mMoreMenuItem = [CCMenuItemImage
						 itemFromNormalSprite:wMoreOffItem
						 selectedSprite:wMoreOnItem 
						 target:self 
						 selector:@selector(menuButtonTapped:)];

		// Setup the main menu items (play, scores, more)
		CCMenu *mainMenu = [CCMenu menuWithItems:mPlayMenuItem, mScoresMenuItem, mMoreMenuItem, nil];
		//[mainMenu alignItemsVerticallyWithPadding:0.0f]; Seems to add a pixel gap
		[mainMenu alignItemsVerticallyWithPadding:-0.5f];
		mainMenu.position = ccp(wHalfWidth, 60); // (Three menu items = 320 x 120, so move up the menu group by 60 pixels)
		[self addChild:mainMenu z:100];
		
		// Set the offset for main menu text (all items are same height so just use the play menu item)
		CGPoint wOffset = ccp(46, mPlayMenuItem.contentSize.height / 2.0f);
		
		// Menu text
		CCLabelBMFont *wPlayLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"PLAY_MENU", nil) fntFile:[GameController selectFont:kDroidSansBold28White]];
		[mPlayMenuItem addChild:wPlayLabel z:4];
		wPlayLabel.anchorPoint = CGPointMake(0.0f, 0.5f);
		wPlayLabel.position = wOffset;

        CCLabelBMFont *wScoresLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"SCORES_MENU", nil) fntFile:[GameController selectFont:kDroidSansBold28White]];
		[mScoresMenuItem addChild:wScoresLabel z:4];
		wScoresLabel.anchorPoint = CGPointMake(0.0f, 0.5f);
		wScoresLabel.position = wOffset;
		
        CCLabelBMFont *wMoreLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"MORE_MENU", nil) fntFile:[GameController selectFont:kDroidSansBold28White]];
		[mMoreMenuItem addChild:wMoreLabel z:4];
		wMoreLabel.anchorPoint = CGPointMake(0.0f, 0.5f);
		wMoreLabel.position = wOffset;
		
		CGFloat wStopHeight = winSize.height + 50;

		// Create an array of elevators
		mElevators = [[CCArray array] retain];
		
		// Establish where the elevators are located
		[mElevators addObject: [MainMenuLargeElevator initWithStartLocation:ccp(210, -30)
															   stopLocation:ccp(210, wStopHeight + 300) 
																   duration:3.0f]];
		[self addChild: [mElevators lastObject] z:21];
		
		
		// Prepare all elevators for the demo
		id<IDemoElevator> wElevator;
		CCARRAY_FOREACH(mElevators, wElevator)
		{
			if(wElevator)
				[wElevator prepareDemo];
		}
				
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
	[mElevators dealloc];
	[super dealloc];
}

- (void) onEnterTransitionDidFinish
{
    // Start intro music
    [[AudioController sharedInstance] musicOff];
    [[AudioController sharedInstance] playSound:kIntroLoop];
    
	id<IDemoElevator> wElevator;
	CCARRAY_FOREACH(mElevators, wElevator)
	{
		if(wElevator)
			[wElevator beginDemo];
	}
	
	[super onEnterTransitionDidFinish];
}

- (void) onExit
{
	// Not necessary for deallocation but the frame cache, no doubt, maintains
	// a reference to the sprites
    // Switch graphics based upon the aspect ratio (iPhone 5)
    if([GameController sharedInstance].is16x9Device)
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrameByName:@"MainMenui5.plist"];
    else
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"MainMenu.plist"];
    
	[super onExit];
}

#pragma mark Implementation of IMenuHandler ______________

- (void)menuButtonTapped:(id)sender 
{
	CCMenuItem *wItem = (CCMenuItem *)sender;
    
    // Disallow is we're waiting for play to continue
    if(mPlayClicked)
        return;
    
    // Stop the intro loop music
    [[AudioController sharedInstance] stopSound:kIntroLoop];

	if (wItem == mPlayMenuItem) 
	{
        // Flag as clicked but unschedule the selectors since
        // we don't care about further touch events
        mPlayClicked = YES;
		[[AudioController sharedInstance] playSound:kClickMenuButton];
        
        [[CCDirector sharedDirector] 
         replaceScene:[CCTransitionMoveInT
                       transitionWithDuration:TRANSITION_DURATION 
                       scene:[GameLayer node]]]; 
        
		[self unscheduleSelectors];
		[self cleanup];
	}
	
	if(wItem == mMoreMenuItem)
	{
		[[AudioController sharedInstance] playSound:kClickMenuButton];
		[self unscheduleSelectors];
		
		[[CCDirector sharedDirector] 
		 replaceScene:[CCTransitionMoveInT
					transitionWithDuration:TRANSITION_DURATION 
					scene:[OptionsMenuLayer node]]];
	}
    
    if(wItem == mScoresMenuItem)
	{
		[[AudioController sharedInstance] playSound:kClickMenuButton];
		[self unscheduleSelectors];
		
		[[CCDirector sharedDirector] 
		 replaceScene:[CCTransitionMoveInT
                       transitionWithDuration:TRANSITION_DURATION 
                       scene:[ScoreMenuLayer node]]];
	}
}

-(void)unscheduleSelectors
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[mPlayMenuItem unschedule:@selector(menuButtonTapped:)];
	[mScoresMenuItem unschedule:@selector(menuButtonTapped:)];
	[mMoreMenuItem unschedule:@selector(menuButtonTapped:)];
}

@end
