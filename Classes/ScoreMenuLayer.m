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

#import "ScoreMenuLayer.h"
#import "MainMenuLayer.h"
#import "GameController.h"
#import "AudioController.h"
#import "GameScore.h"
#import "GCHelper.h"

@implementation ScoreMenuLayer

-(id) init
{
	if( (self = [super init]) )
	{
        //CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGRect winRect = [[GameController sharedInstance] gamingAreaRectForPlay:NO];
		CGSize winSize = winRect.size;
		int wHalfWidth = winSize.width / 2;
        
        UInt8 wHeightBumpFor16x9 = 0;
		
        // Switch graphics based upon the aspect ratio (iPhone 5)
        if([GameController sharedInstance].is16x9Device)
        {
            wHeightBumpFor16x9 = VERTICAL_BUMP_FOR_16X9;
           [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ScoresMenui5.plist"];
        }
        else
        {
           [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ScoresMenu.plist"];
        }
        
        // Only play the fade in on subsequent labels
        mFirstShowing = YES;
        
        // Assume there are no valid scores; we'll read the highScoreArray a few lines later
        mValidScores = 0;
        
		// Background
		CCSprite *wBackground = [CCSprite spriteWithSpriteFrameName:@"high-scores-bg.png"];
		[wBackground setAnchorPoint:CGPointZero];
		wBackground.position = CGPointZero;
		[self addChild: wBackground z:0];
        
        // ...and treasure graphic
        CCSprite *wLogo = [CCSprite spriteWithSpriteFrameName:@"treasure-scores.png"];
		wLogo.position = CGPointMake(wHalfWidth, 220 + wHeightBumpFor16x9);
		[self addChild:wLogo z:1];
        
        // Game Center menu item
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
		
		// Back menu item
		CCSprite *wMoreOnItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-on.png"];
		CCSprite *wMoreOffItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-off.png"];
		
		mBackButton = [CCMenuItemImage
					   itemFromNormalSprite:wMoreOffItem
					   selectedSprite:wMoreOnItem 
					   target:self 
					   selector:@selector(menuButtonTapped:)];
		
		// Setup the menu item
		CCMenu *wMenu = [CCMenu menuWithItems:mGameCenterButton, mBackButton, nil];
		[wMenu alignItemsVerticallyWithPadding:-0.5f];
		wMenu.position = ccp(wHalfWidth, 40); // (Two menu items = 320 x 80, so move up the menu group by 40 pixels)
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
		
		// Establish all strings
		mStringArray = [[CCArray arrayWithCapacity:18] retain];
        mStringEasternArray = [[CCArray arrayWithCapacity:18] retain];
        
        // Count the number of high scores (objects in highScoreArray that are NOT nil)
        GameScore* wScore = nil;
        GameController* gc = [GameController sharedInstance];
        for(UInt8 i = 0; i < gc.highScoreArray.count; i++)
        {
            wScore = (GameScore*)[gc.highScoreArray objectAtIndex:i]; 
            if(wScore != nil)
            {
                [mStringArray addObject:wScore.localizedDateAndTime];
                [mStringEasternArray addObject:wScore.localizedDateAndTime];
                
                if(![GameController isChineseLang])
                {
                    // Most languages - just combine "Level" and "#" score value
                    [mStringArray addObject:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"LEVEL_LABEL", nil), wScore.localizedLevel]];
                    [mStringEasternArray addObject:@""];
                }
                else
                {
                    // Chinese - show "Level" in STHeiti font, the number in LeagueGothic
                    [mStringArray addObject:[NSString stringWithFormat:@"%@", NSLocalizedString(@"LEVEL_LABEL", nil)]];
                    [mStringEasternArray addObject:[NSString stringWithFormat:@"%@", wScore.localizedLevel]];
                }
                
                [mStringArray addObject:wScore.localizedPension];
                [mStringEasternArray addObject:wScore.localizedPension];
                
                mValidScores++;
            }
        }
        
        // There are no high scores yet!
        if(mValidScores == 0) 
        {
            [mStringArray addObject:NSLocalizedString(@"NO_HIGH_SCORES", nil)];
            [mStringEasternArray addObject:NSLocalizedString(@"NO_HIGH_SCORES", nil)];
            [mStringArray addObject:NSLocalizedString(@"", nil)];
            [mStringEasternArray addObject:@""];
            [mStringArray addObject:NSLocalizedString(@"", nil)];
            [mStringEasternArray addObject:@""];
        }

		// Setup the four areas of text
		
		// Scores
        CCLabelBMFont *wTitle = [CCLabelBMFont labelWithString:NSLocalizedString(@"SCORES_MENU", nil) fntFile:[GameController selectFont:kLeague72White]];
        wTitle.scale = ([GameController isChineseLang]) ? 0.6f : 0.7f;
		wTitle.position = ccp(wHalfWidth, 290 + wHeightBumpFor16x9);
		[self addChild:wTitle];
		
		// Text for score date/time
		NSString *wText1 = (NSString*)[mStringArray objectAtIndex:0];
        CCLOG(@"Trying to display date... %@", wText1);
        CCLOG(@"Is Chinese locality... %d", [GameController isChineseLocale]);
    
        // Row 1 requires localization to display the "no high scores yet" label
		CCLabelBMFont *wRow1;
        if(mValidScores == 0)
            wRow1 = [CCLabelBMFont labelWithString:wText1 fntFile:[GameController selectFont:kLeague24White]];
        else
            wRow1 = [CCLabelBMFont labelWithString:wText1 fntFile:[GameController selectFont:kLeague24White forceDefault:YES]];
        
		wRow1.position = ccp(wHalfWidth, 150 + wHeightBumpFor16x9);
		[self addChild:wRow1 z:10 tag:10];
		
		// Text for level achieved
        if(![GameController isChineseLang])
        {
            wText1 = (NSString*)[mStringArray objectAtIndex:1];
            CCLabelBMFont *wRow2 = [CCLabelBMFont labelWithString:wText1 fntFile:[GameController selectFont:kLeague24White]];
            wRow2.position = ccp(wHalfWidth, 125 + wHeightBumpFor16x9);
            [self addChild:wRow2 z:20 tag:20];
            // Add a font just for consistency with Chinese
            CCLabelBMFont *wRow2e = [CCLabelBMFont labelWithString:@"" fntFile:[GameController selectFont:kLeague24White forceDefault:YES]];
            wRow2e.visible = NO;
            [self addChild:wRow2e z:25 tag:25];
        }
        else
        {
            // Add the "Level" text first...
            wText1 = (NSString*)[mStringArray objectAtIndex:1];
            CCLabelBMFont *wRow2 = [CCLabelBMFont labelWithString:wText1 fntFile:[GameController selectFont:kLeague24White]];
            wRow2.position = ccp(wHalfWidth - 15, 125 + wHeightBumpFor16x9);
            [self addChild:wRow2 z:20 tag:20];
            // ...and finally the level value
            wText1 = (NSString*)[mStringEasternArray objectAtIndex:1];
            // Ensure the level value is always displayed in the default font
            CCLabelBMFont *wRow2e = [CCLabelBMFont labelWithString:wText1 fntFile:[GameController selectFont:kLeague24White forceDefault:YES]];
            wRow2e.position = ccp(wHalfWidth + 20, 123 + wHeightBumpFor16x9);
            [self addChild:wRow2e z:25 tag:25];
        }
		
		// Text for pension achieved
		wText1 = (NSString*)[mStringArray objectAtIndex:2];
		CCLabelBMFont *wRow3 = [CCLabelBMFont labelWithString:wText1 fntFile:[GameController selectFont:kLeague24White forceDefault:YES]];
		wRow3.position = ccp(wHalfWidth, 100 + wHeightBumpFor16x9);
		[self addChild:wRow3 z:30 tag:30];
		
        // This is used to calculate how many screens are flashed
		mScoreRows = 3;
		mScoreSlideNumber = 0;
        
        [self scheduleUpdate];
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
    [self unscheduleUpdate];
    [mStringArray release];
    [mStringEasternArray release];
	[super dealloc];
}

-(void) update:(ccTime) dt
{
    GCHelper* wGCHelp = [GCHelper sharedGCHelper];
    mGameCenterButton.visible = wGCHelp.gameCenterFeaturesEnabled;
}

- (void) onEnterTransitionDidFinish
{
    // Only flash if there are actual high scores.
    if(mValidScores > 1)
        [self flashScore];
    
    // Authenticate the player if not already
    [[GCHelper sharedGCHelper] authenticateLocalPlayer];
    
	[super onEnterTransitionDidFinish];
}

- (void) onExit
{
    // Switch graphics based upon the aspect ratio (iPhone 5)
    if([GameController sharedInstance].is16x9Device)
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrameByName:@"ScoresMenui5.plist"];
    else
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"ScoresMenu.plist"];
    
	[super onExit];
}

-(void)unscheduleSelectors
{
	[mBackButton unschedule:@selector(menuButtonTapped:)];
    [mGameCenterButton unschedule:@selector(menuButtonTapped:)];
}

-(void)flashScore
{
	float wScoreScreenTime = (CREDIT_FADE_SEC + CREDIT_HANG_SEC + CREDIT_FADE_SEC);
	
	UInt8 wScoreScreens = mStringArray.count / mScoreRows;
	UInt8 wRow1 = mScoreSlideNumber * mScoreRows;
	UInt8 wRow2 = wRow1 + 1;
	UInt8 wRow3 = wRow2 + 1;
	NSString* wText1 = (NSString*)[mStringArray objectAtIndex:wRow1];
	NSString* wText2 = (NSString*)[mStringArray objectAtIndex:wRow2];
    NSString* wText2e = (NSString*)[mStringEasternArray objectAtIndex:wRow2];
	NSString* wText3 = (NSString*)[mStringArray objectAtIndex:wRow3];
    
	CCLabelBMFont *wLine1 = (CCLabelBMFont*)[self getChildByTag:10];
	CCLabelBMFont *wLine2 = (CCLabelBMFont*)[self getChildByTag:20];
    CCLabelBMFont *wLine2e = (CCLabelBMFont*)[self getChildByTag:25];
	CCLabelBMFont *wLine3 = (CCLabelBMFont*)[self getChildByTag:30];
	
	[wLine1 setString:wText1];
	[wLine2 setString:wText2];
    [wLine2e setString:wText2e];
	[wLine3 setString:wText3];
	
    if(!mFirstShowing)
    {
        [wLine1 runAction:[CCSequence actions:[CCFadeIn actionWithDuration:CREDIT_FADE_SEC],
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC], 
                           nil]];
        [wLine2 runAction:[CCSequence actions:[CCFadeIn actionWithDuration:CREDIT_FADE_SEC],
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC], 
                           nil]];
        [wLine2e runAction:[CCSequence actions:[CCFadeIn actionWithDuration:CREDIT_FADE_SEC],
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC],
                           nil]];
        [wLine3 runAction:[CCSequence actions:[CCFadeIn actionWithDuration:CREDIT_FADE_SEC],
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC], 
                           nil]];
	}
    else 
    {
        mFirstShowing = NO;
        [wLine1 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC], 
                           nil]];
        [wLine2 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC], 
                           nil]];
        [wLine2e runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC],
                           nil]];
        [wLine3 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC], 
                           nil]];
    }
    
	mScoreSlideNumber = (mScoreSlideNumber + 1 > (wScoreScreens -1) ) ? 0 : mScoreSlideNumber + 1; 
	
	CCSequence *wSeq = [CCSequence actions:[CCDelayTime actionWithDuration:(wScoreScreenTime + 0.2f)],
						[CCCallFunc actionWithTarget:self selector:@selector(flashScore)], nil];
    
	[self runAction:wSeq];
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