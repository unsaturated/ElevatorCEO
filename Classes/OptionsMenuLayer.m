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

#import "OptionsMenuLayer.h"
#import "MainMenuLayer.h"
#import "GameController.h"
#import "AudioController.h"
#import "IAPHelper.h"
#import "CCMenuItemSprite+Color.h"

@implementation OptionsMenuLayer

-(id) init
{
	if( (self = [super init]) )
	{
        CGRect winRect = [[GameController sharedInstance] gamingAreaRectForPlay:NO];
		CGSize winSize = winRect.size;
        
		int wHalfWidth = winSize.width / 2;
        
        UInt8 wHeightBumpFor16x9 = 0;
		
        // Switch graphics based upon the aspect ratio (iPhone 5)
        if([GameController sharedInstance].is16x9Device)
        {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MoreMenui5.plist"];
            wHeightBumpFor16x9 = VERTICAL_BUMP_FOR_16X9;
        }
        else
        {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MoreMenu.plist"];
        }
        
        // Subscribe to changes in purchase state
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAdsRemovedByUserMenuItems) name:IAP_PURCHASE_SUCCESS_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAdsInProgressMenuItems) name:IAP_PURCHASE_INPROG_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAdsRemoveFailedMenuItems) name:IAP_PURCHASE_FAILED_NOTIFICATION object:nil];
        
        // Only play the fade in on subsequent labels
        mFirstShowing = YES;
		
		// Background
		CCSprite *wBackground = [CCSprite spriteWithSpriteFrameName:@"more-bg.png"];
		[wBackground setAnchorPoint:winRect.origin];
		wBackground.position = winRect.origin;
		[self addChild: wBackground z:0];
		
		// More menu item
		CCSprite *wMoreOnItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-on.png"];
		CCSprite *wMoreOffItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-off.png"];
		
		mBackButton = [CCMenuItemImage
					   itemFromNormalSprite:wMoreOffItem
					   selectedSprite:wMoreOnItem 
					   target:self 
					   selector:@selector(menuButtonTapped:)];
		
        // Set the offset for main menu text (all items are same height so just use the play menu item)
		CGPoint wOffset = ccp(46, mBackButton.contentSize.height / 2.0f);
		
        CCLabelBMFont *wBackLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"BACK_MENU", nil) fntFile:[GameController selectFont:kDroidSansBold28White]];
		[mBackButton addChild:wBackLabel z:4];
		wBackLabel.anchorPoint = CGPointMake(0.0f, 0.5f);
		wBackLabel.position = wOffset;
        
        // Display the RESTORE and REMOVE ADS button only if the device is 16x9
        if([GameController sharedInstance].is16x9Device)
        {
            // No need to display the REMOVE ADS button if already removed...
            if(![GameController sharedInstance].adsRemovedByUser)
            {

                // Restore purchases menu item
                CCSprite *wRestorePurchaseOnItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-on.png"];
                CCSprite *wRestorePurchaseOffItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-off.png"];
                
                mRestorePurchaseButton = [CCMenuItemImage
                                          itemFromNormalSprite:wRestorePurchaseOffItem
                                          selectedSprite:wRestorePurchaseOnItem
                                          target:self
                                          selector:@selector(menuButtonTapped:)];
                
                // Text for the RESTORE PURCHASE button
                CCLabelBMFont *wRestorePurchaseLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"RESTORE_PURCHASE", nil) fntFile:[GameController selectFont:kDroidSansBold28White]];
                [mRestorePurchaseButton addChild:wRestorePurchaseLabel z:4];
                wRestorePurchaseLabel.anchorPoint = CGPointMake(0.0f, 0.5f);
                wRestorePurchaseLabel.position = wOffset;
                
                // Remove Ads menu item
                CCSprite *wRemoveAdsOnItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-on.png"];
                CCSprite *wRemoveAdsOffItem = [CCSprite spriteWithSpriteFrameName:@"main-menu-bar-off.png"];
                
                mRemoveAdsButton = [CCMenuItemImage
                                    itemFromNormalSprite:wRemoveAdsOffItem
                                    selectedSprite:wRemoveAdsOnItem
                                    target:self
                                    selector:@selector(menuButtonTapped:)];
                
                // Text for the REMOVE ADS button
                CCLabelBMFont *wRemoveAdsLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"REMOVE_ADS", nil) fntFile:[GameController selectFont:kDroidSansBold28White]];
                [mRemoveAdsButton addChild:wRemoveAdsLabel z:4];
                wRemoveAdsLabel.anchorPoint = CGPointMake(0.0f, 0.5f);
                wRemoveAdsLabel.position = wOffset;
                
                // Setup the menu items
                CCMenu *wMenu = [CCMenu menuWithItems:mRestorePurchaseButton, mRemoveAdsButton, mBackButton, nil];
                [wMenu alignItemsVerticallyWithPadding:-0.5f];
                wMenu.position = ccp(wHalfWidth, 60);
                [self addChild:wMenu z:100];
            }
            else
            {
                // Ads were removed by the user
                // Setup the menu items
                CCMenu *wMenu = [CCMenu menuWithItems:mBackButton, nil];
                [wMenu alignItemsVerticallyWithPadding:-0.5f];
                wMenu.position = ccp(wHalfWidth, 20);
                [self addChild:wMenu z:100];
            }
        }
        else
        {
            // Setup the menu item
            CCMenu *wMenu = [CCMenu menuWithItems:mBackButton, nil];
            [wMenu alignItemsVerticallyWithPadding:-0.5f];
            wMenu.position = ccp(wHalfWidth, 20);
            [self addChild:wMenu z:100];
        }
		
		// Establish all strings
		mStringArray = [[CCArray arrayWithCapacity:18] retain];
        // Set whether each string is supported by my Eastern character font sheet
        mStringIsEasternScriptReady = [[CCArray arrayWithCapacity:18] retain];

		// Matthew Crumley
		// © 2018
		// matt.unsaturated.com
		[mStringArray addObject:@"Matthew Crumley"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"© 2018"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"matt.unsaturated.com"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		
		// CREDITS_GAME_DESIGN = "Game Design and Development"
		// Matthew Crumley
		// matt.unsaturated.com
		[mStringArray addObject:NSLocalizedString(@"CREDITS_GAME_DESIGN", nil)];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:YES]];
		[mStringArray addObject:@"Matthew Crumley"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"matt.unsaturated.com"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		
		// Game Engine
		// Cocos 2D
		// cocos2d-iphone.org
		[mStringArray addObject:NSLocalizedString(@"CREDITS_GAME_ENGINE", nil)];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:YES]];
		[mStringArray addObject:@"Cocos 2D"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"cocos2d-iphone.org"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];

		// “Small World” Art
		// Daniel Cook
		// lostgarden.com
		[mStringArray addObject:@"\"Small World\" Art"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"Daniel Cook"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"lostgarden.com"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
        
        // CREDITS_ADDITIONAL = "Additional Support"
		[mStringArray addObject:NSLocalizedString(@"CREDITS_ADDITIONAL", nil)];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:YES]];
		[mStringArray addObject:@"Dan Engler"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@""];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];

		[mStringArray addObject:NSLocalizedString(@"CREDITS_ADDITIONAL", nil)];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:YES]];
		[mStringArray addObject:@"Kristien Crumley"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@""];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
        
		[mStringArray addObject:NSLocalizedString(@"CREDITS_ADDITIONAL", nil)];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:YES]];
		[mStringArray addObject:@"Thuy Dang"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"Ian Dang"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
        
		[mStringArray addObject:NSLocalizedString(@"CREDITS_ADDITIONAL", nil)];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:YES]];
		[mStringArray addObject:@"Mike Dunne"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"Phoebe Dunne, Tommy Dunne"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
        
		[mStringArray addObject:NSLocalizedString(@"CREDITS_ADDITIONAL", nil)];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:YES]];
		[mStringArray addObject:@"Greg Auerbach"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"Evan Auerbach"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
        
		[mStringArray addObject:NSLocalizedString(@"CREDITS_ADDITIONAL", nil)];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:YES]];
		[mStringArray addObject:@"Mike Nunez"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@""];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
        
		[mStringArray addObject:NSLocalizedString(@"CREDITS_ADDITIONAL", nil)];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:YES]];
		[mStringArray addObject:@"Michael Wallick"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@""];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
        
		// CREDITS_AUDIO = "Audio"
        [mStringArray addObject:NSLocalizedString(@"CREDITS_AUDIO", nil)];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:YES]];
		[mStringArray addObject:@"Audiosparx"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"audiosparx.com"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
        
        [mStringArray addObject:NSLocalizedString(@"CREDITS_AUDIO", nil)];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:YES]];
		[mStringArray addObject:@"Music Loops"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"musicloops.com"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
        
		[mStringArray addObject:NSLocalizedString(@"CREDITS_AUDIO", nil)];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:YES]];
		[mStringArray addObject:@"Sound Rangers"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"soundrangers.com"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
        
        // Fonts
		[mStringArray addObject:@"\"League Gothic\" Font"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"The League of Moveable Type"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];
		[mStringArray addObject:@"theleagueofmoveabletype.com"];
        [mStringIsEasternScriptReady addObject:[NSNumber numberWithBool:NO]];

		
		// Setup the four areas of text
		
		// Elevator CEO
        CCLabelBMFont *wTitle = [CCLabelBMFont labelWithString:NSLocalizedString(@"ELEVATOR_CEO", nil) fntFile:[GameController selectFont:kLeague72White]];
        wTitle.scale = ([GameController isChineseLang]) ? 0.35f : 0.7f;
		wTitle.position = ccp(wHalfWidth, 280 + wHeightBumpFor16x9);
		[self addChild:wTitle];
		
		// Text for Credit - Row 1 (Western character sets)
		NSString *wText = (NSString*)[mStringArray objectAtIndex:0];
        CCLabelBMFont *wRow1 = [CCLabelBMFont labelWithString:wText fntFile:[GameController selectFont:kDroidSansBold13White forceDefault:YES]];
		wRow1.position = ccp(wHalfWidth, 200 + wHeightBumpFor16x9);
		[self addChild:wRow1 z:10 tag:10];
        
        // Text for Credit - Row 1 (Eastern character sets)
        // This overlays the preceding row but the visibility is toggled based upon which font is required
        CCLabelBMFont *wRow1Eastern = [CCLabelBMFont labelWithString:@"" fntFile:[GameController selectFont:kDroidSansBold13White]];
		wRow1Eastern.position = ccp(wHalfWidth, 200 + wHeightBumpFor16x9);
        wRow1Eastern.visible = NO;
		[self addChild:wRow1Eastern z:15 tag:15];
        
		// Text for Credit - Row 2
		wText = (NSString*)[mStringArray objectAtIndex:1];
		CCLabelBMFont *wRow2 = [CCLabelBMFont labelWithString:NSLocalizedString(wText, nil) fntFile:[GameController selectFont:kDroidSansBold13White forceDefault:YES]];
		wRow2.position = ccp(wHalfWidth, 175 + wHeightBumpFor16x9);
		[self addChild:wRow2 z:20 tag:20];
		
		// Text for Credit - Row 3
		wText = (NSString*)[mStringArray objectAtIndex:2];
		CCLabelBMFont *wRow3 = [CCLabelBMFont labelWithString:NSLocalizedString(wText, nil) fntFile:[GameController selectFont:kDroidSansBold13White forceDefault:YES]];
		wRow3.position = ccp(wHalfWidth, 150 + wHeightBumpFor16x9);
		[self addChild:wRow3 z:30 tag:30];
		
		mCreditRows = 3;
		mCreditSlideNumber = 0;
        
        // Try again to retrieve product list, if it's empty
        if([IAPHelper sharedInstance].productList == nil)
        {
            [[IAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
                if(success)
                {
                    CCLOG(@"IAP product list was retrieved.");
                }
                else
                {
                    CCLOG(@"IAP product list was NOT retrieved.");
                }
            }];
        }
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
	[super dealloc];
}


- (void) onEnterTransitionDidFinish
{
	[self flashCredits];
	[super onEnterTransitionDidFinish];
}

- (void) onExit
{
    // Switch graphics based upon the aspect ratio (iPhone 5)
    if([GameController sharedInstance].is16x9Device)
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"MoreMenui5.plist"];
    else
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"MoreMenu.plist"];
    
    [self unscheduleSelectors];
	[super onExit];
}

-(void)unscheduleSelectors
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [mStringArray removeAllObjects];
    [mStringArray release];
    [mStringIsEasternScriptReady removeAllObjects];
    [mStringIsEasternScriptReady release];
	[mBackButton unschedule:@selector(menuButtonTapped:)];
    [mRestorePurchaseButton unschedule:@selector(menuButtonTapped:)];
    [mRemoveAdsButton unschedule:@selector(menuButtonTapped:)];
}

-(void)flashCredits
{
	float wCreditScreenTime = (CREDIT_FADE_SEC + CREDIT_HANG_SEC + CREDIT_FADE_SEC);
	
	UInt8 wCreditScreens = mStringArray.count / mCreditRows;
	UInt8 wRow1 = mCreditSlideNumber * mCreditRows;
	UInt8 wRow2 = wRow1 + 1;
	UInt8 wRow3 = wRow2 + 1;
	NSString* wText1 = (NSString*)[mStringArray objectAtIndex:wRow1];
	NSString* wText2 = (NSString*)[mStringArray objectAtIndex:wRow2];
	NSString* wText3 = (NSString*)[mStringArray objectAtIndex:wRow3];
		
	CCLabelBMFont *wLine1  = (CCLabelBMFont*)[self getChildByTag:10];
    CCLabelBMFont *wLine1e = (CCLabelBMFont*)[self getChildByTag:15];
	CCLabelBMFont *wLine2  = (CCLabelBMFont*)[self getChildByTag:20];
	CCLabelBMFont *wLine3  = (CCLabelBMFont*)[self getChildByTag:30];
	
    // Set the string based upon whether it supports Eastern font
    // Only wLine1e can support Eastern character sets
    if(!((NSNumber*)[mStringIsEasternScriptReady objectAtIndex:wRow1]).boolValue)
    {
        [wLine1 setString:wText1];
        wLine1.visible = YES;
        wLine1e.visible = NO;
    }
    else
    {
        [wLine1e setString:wText1];
        wLine1.visible = NO;
        wLine1e.visible = YES;
    }
    
	[wLine2 setString:wText2];
	[wLine3 setString:wText3];
	
    if(!mFirstShowing)
    {
        [wLine1 runAction:[CCSequence actions:[CCFadeIn actionWithDuration:CREDIT_FADE_SEC],
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC], 
                           nil]];
        [wLine1e runAction:[CCSequence actions:[CCFadeIn actionWithDuration:CREDIT_FADE_SEC],
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC],
                           nil]];
        [wLine2 runAction:[CCSequence actions:[CCFadeIn actionWithDuration:CREDIT_FADE_SEC],
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
        [wLine1e runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC],
                           nil]];
        [wLine2 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC], 
                           nil]];
        [wLine3 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:CREDIT_HANG_SEC],
                           [CCFadeOut actionWithDuration:CREDIT_FADE_SEC], 
                           nil]];
    }
    
	mCreditSlideNumber = (mCreditSlideNumber + 1 > (wCreditScreens -1) ) ? 0 : mCreditSlideNumber + 1; 
	
	CCSequence *wSeq = [CCSequence actions:[CCDelayTime actionWithDuration:(wCreditScreenTime + 0.2f)],
						[CCCallFunc actionWithTarget:self selector:@selector(flashCredits)], nil];

	[self runAction:wSeq];
}

- (void)menuButtonTapped:(id)sender 
{
	CCMenuItem *wItem = (CCMenuItem *)sender;
	
	if (wItem == mBackButton) 
	{
		[[AudioController sharedInstance] playSound:kClickMenuButton];
		
		[[CCDirector sharedDirector] 
		 replaceScene:[CCTransitionMoveInB
					   transitionWithDuration:TRANSITION_DURATION 
					   scene:[MainMenuLayer node]]];
	}
    else if (wItem == mRemoveAdsButton)
    {
        IAPHelper* iap = [IAPHelper sharedInstance];
        SKProduct* product = [iap productObjectFromList:IAP_REMOVE_ADS_KEY];
        [[IAPHelper sharedInstance] buyProduct:product];
    }
    else if (wItem == mRestorePurchaseButton)
    {
        [[IAPHelper sharedInstance] restoreCompletedTransactions];
    }
}

- (void)setAdsRemovedByUserMenuItems
{
    // Don't remove and cleanup, just set to invisible; all buttons are cleaned up later
    [mRestorePurchaseButton setVisible:NO];
    [mRemoveAdsButton setVisible:NO];
}

-(void) setAdsInProgressMenuItems
{
    CCMenuItemImage* wMenu;
    
    wMenu = (CCMenuItemImage*)mRemoveAdsButton;
    [wMenu setMenuItemDisabled];
    
    wMenu = (CCMenuItemImage*)mRestorePurchaseButton;
    [wMenu setMenuItemDisabled];
}

-(void) setAdsRemoveFailedMenuItems
{
    CCMenuItemImage* wMenu;
    
    wMenu = (CCMenuItemImage*)mRemoveAdsButton;
    [wMenu setMenuItemEnabled];
    
    wMenu = (CCMenuItemImage*)mRestorePurchaseButton;
    [wMenu setMenuItemEnabled];
}

@end
