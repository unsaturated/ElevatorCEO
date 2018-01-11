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

#import "GameOverLayer.h"
#import "MainMenuLayer.h"
#import "GameController.h"
#import "AudioController.h"
#import "GCHelper.h"

@implementation GameOverLayer

+(id) gameOver:(float)pension withLevel:(UInt16)level
{
    return [[[self alloc] initGameOver:pension withLevel:level] autorelease];
}

-(id) initGameOver:(float)pension withLevel:(UInt16)level
{
	if( (self = [self init]) )
	{
        mPension = pension;
        
        BOOL wIsTopThree = [[GameController sharedInstance] setPension:pension withLevel:level];
        
        // Send the score to GC if greater than zero
        if(pension > 0)
            [[GCHelper sharedGCHelper] submitScore:pension category:SCORE_ARCHIVE_KEY];
        
        if(wIsTopThree)
        {
            [mTopThree setString:NSLocalizedString(@"TOP_THREE_SCORE", nil)];
            [mTopThree setColor:ccc3(255, 0, 0)];
            [mTopThree runAction:[CCRepeatForever 
                                  actionWithAction:[CCSequence actions:
                                                    [CCScaleTo actionWithDuration:0.7f scale:1.2f], 
                                                    [CCScaleTo actionWithDuration:0.7f scale:0.8f], nil]]];
        }
        
        // Format the level total as a single string (all the same character set)
        if(![GameController isChineseLang])
        {
            [mLevelLabel setString:[NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"LEVEL_LABEL", nil), level]];
        }
        else
        {
            // ...or format as Chinese, which means a mixed character set
            [mLevelLabel setString:[NSString stringWithFormat:@"%@", NSLocalizedString(@"LEVEL_LABEL", nil)]];
            [mLevelLabelExtended setString:[NSString stringWithFormat:@"%d", level]];
        }

        NSString* formattedPension = [mFormatter stringFromNumber:[NSNumber numberWithFloat:pension]];
		[mPensionLabel setString:[GameController convertToAscii:formattedPension]];
	}
	
	return self;
}

-(id) init
{
	if( (self = [super init]) )
	{
        CGRect winRect = [[GameController sharedInstance] gamingAreaRectForPlay:NO];
		CGSize winSize = winRect.size;
		int wHalfWidth = winSize.width / 2;
        int wHeightBumpFor16x9 = 0;
		
        // Switch graphics based upon the aspect ratio (iPhone 5)
        if([GameController sharedInstance].is16x9Device)
        {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"GameOveri5.plist"];
            wHeightBumpFor16x9 = 30;
        }
        else
        {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"GameOver.plist"];
        }
		
		// Background
		CCSprite *wBackground = [CCSprite spriteWithSpriteFrameName:@"game-over-bg.png"];
		[wBackground setAnchorPoint:CGPointZero];
		wBackground.position = CGPointZero;
		[self addChild: wBackground z:0];
        
        CCSprite *gcOn = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-on.png"];
        CCSprite *gcOff = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-off.png"];
        
        mGameCenterButton = [CCMenuItemImage
                             itemFromNormalSprite:gcOff
                             selectedSprite:gcOn
                             target:self
                             selector:@selector(menuButtonTapped:)];
        
        // Determine whether GC is enabled before the button is ever displayed
        GCHelper* wGCHelp = [GCHelper sharedGCHelper];
        mGameCenterButton.visible = wGCHelp.gameCenterFeaturesEnabled;
		
		// More menu item
		CCSprite *wMoreOnItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-on.png"];
		CCSprite *wMoreOffItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-off.png"];
		
		mBackButton = [CCMenuItemImage
					   itemFromNormalSprite:wMoreOffItem
					   selectedSprite:wMoreOnItem 
					   target:self 
					   selector:@selector(menuButtonTapped:)];
		
		// Setup the menu items (game center, back)
		CCMenu *wMenu = [CCMenu menuWithItems:mGameCenterButton, mBackButton, nil];
		[wMenu alignItemsVerticallyWithPadding:-0.5f];
		wMenu.position = ccp(wHalfWidth, 40);
		[self addChild:wMenu z:100 tag:1001];
		
		// Set the offset for main menu text (all items are same height so just use the play menu item)
		CGPoint wOffset = ccp(46, mBackButton.contentSize.height / 2.0f);
		
		CCLabelBMFont *wBackLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"BACK_MENU", nil) fntFile:[GameController selectFont:kDroidSansBold28White]];
		[mBackButton addChild:wBackLabel z:4];
		wBackLabel.anchorPoint = CGPointMake(0.0f, 0.5f);
		wBackLabel.position = wOffset;
        
        CCLabelBMFont *wGameCenterLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"GAME_CENTER", nil) fntFile:[GameController selectFont:kDroidSansBold28White forceDefault:YES]];
		[mGameCenterButton addChild:wGameCenterLabel z:4 tag:500];
		wGameCenterLabel.anchorPoint = CGPointMake(0.0f, 0.5f);
		wGameCenterLabel.position = wOffset;
        
        // Localize the pension amount
		mFormatter = [[[NSNumberFormatter alloc] init] retain];
		[mFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[mFormatter setMaximumFractionDigits:0];
				
		// Setup the three areas of text - GAME OVER, Pension, and Level
		
		// GAME OVER
        if(![GameController isChineseLang])
        {
            CCLabelBMFont *wTitleGame = [CCLabelBMFont labelWithString:@"GAME" fntFile:[GameController selectFont:kLeague72White forceDefault:YES]];
            wTitleGame.position = ccp(wHalfWidth, 280 + wHeightBumpFor16x9);
            [self addChild:wTitleGame];
            
            CCLabelBMFont *wTitleOver = [CCLabelBMFont labelWithString:@"OVER" fntFile:[GameController selectFont:kLeague72White forceDefault:YES]];
            wTitleOver.position = ccp(wHalfWidth, 220 + wHeightBumpFor16x9);
            [self addChild:wTitleOver];
        }
        else
        {
            // In Chinese simplified: 游戏结束
            CCLabelBMFont *wTitleGame = [CCLabelBMFont labelWithString:@"游戏结束" fntFile:[GameController selectFont:kLeague72White]];
            wTitleGame.position = ccp(wHalfWidth, 250 + wHeightBumpFor16x9);
            wTitleGame.scale = 0.6f;
            [self addChild:wTitleGame];
        }
        
        // Test for TOP THREE!
        mTopThree = [CCLabelBMFont labelWithString:@"" fntFile:[GameController selectFont:kLeague24White]];
        mTopThree.position = ccp(wHalfWidth, 160 + wHeightBumpFor16x9);
        [self addChild:mTopThree z:11 tag:10];
        		
        // Text for Level
        if(![GameController isChineseLang])
        {
            mLevelLabel = [CCLabelBMFont labelWithString:@"0" fntFile:[GameController selectFont:kLeague24White forceDefault:YES]];
            mLevelLabel.position = ccp(wHalfWidth, 125 + wHeightBumpFor16x9);
            [self addChild:mLevelLabel z:11 tag:20];
        }
        else
        {
            // "Level" gets translated into Chinese
            mLevelLabel = [CCLabelBMFont labelWithString:@"0" fntFile:[GameController selectFont:kLeague24White]];
            mLevelLabel.position = ccp(wHalfWidth - 10, 125 + wHeightBumpFor16x9);
            [self addChild:mLevelLabel z:11 tag:20];
            
            mLevelLabelExtended = [CCLabelBMFont labelWithString:@"0" fntFile:[GameController selectFont:kLeague24White forceDefault:YES]];
            mLevelLabelExtended.position = ccp(wHalfWidth + 20, 125 + wHeightBumpFor16x9);
            [self addChild:mLevelLabelExtended z:11 tag:25];
        }
        
		// Text for Pension
		mPensionLabel = [CCLabelBMFont labelWithString:@"0" fntFile:[GameController selectFont:kLeague24White forceDefault:YES]];
		mPensionLabel.position = ccp(wHalfWidth, 100 + wHeightBumpFor16x9);
		[self addChild:mPensionLabel z:10 tag:30];
        
        [self scheduleUpdate];
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

- (void) dealloc
{
    [self unscheduleUpdate];
	CCLOG(@"---DEALLOC %@", self);
	[super dealloc];
}

-(void) update:(ccTime) dt
{
    GCHelper* wGCHelp = [GCHelper sharedGCHelper];
    mGameCenterButton.visible = wGCHelp.gameCenterFeaturesEnabled;
}

-(void)onEnter
{
    [[GameController sharedInstance] animateAdBannerIntoView:NO];
    [[AudioController sharedInstance] musicOff];
    [[AudioController sharedInstance] soundOn];
    
    [super onEnter];
}

- (void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
    // If the game had a significant score then set the event
    if(mPension > GAME_MIN_RATE_APP_PENSION)
    {
        // Prompt to rate the game
    }
}

- (void) onExit
{
    // Switch graphics based upon the aspect ratio (iPhone 5)
    if([GameController sharedInstance].is16x9Device)
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"GameOveri5.plist"];
    else
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"GameOver.plist"];
    
	[super onExit];
}

-(void)unscheduleSelectors
{
	[mBackButton unschedule:@selector(menuButtonTapped:)];
    [mGameCenterButton unschedule:@selector(menuButtonTapped:)];
}

- (void)menuButtonTapped:(id)sender 
{
	CCMenuItem *wItem = (CCMenuItem *)sender;
	
	if (wItem == mBackButton) 
	{		
		[[AudioController sharedInstance] playSound:kClickMenuButton];
		[self unscheduleSelectors];
		[[CCDirector sharedDirector] 
		 replaceScene:[CCTransitionMoveInB
					   transitionWithDuration:TRANSITION_DURATION 
					   scene:[MainMenuLayer node]]];
	}
    if(wItem == mGameCenterButton)
    {
        // Display the Game Center unified view-controller
        [[GCHelper sharedGCHelper] displayUnifiedController];
    }
}

@end
