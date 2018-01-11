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

#import "GamePauseLayer.h"

@implementation GamePauseLayer

-(id) init
{
	if( (self=[super init] )) 
	{
        CGSize winSize = [[GameController sharedInstance] gamingAreaRectForPlay:YES].size;
        
        // Set the size to be the 
		[self setContentSize:CGSizeMake(240.0f, winSize.height)];
		[self setAnchorPoint:CGPointMake(0.0f, 0.0f)];
		
        CCLayerColor* wBackground = [CCLayerColor layerWithColor:PAUSE_BG_COLOR width:240.0f height:winSize.height];
        [wBackground setAnchorPoint:CGPointZero];
		wBackground.position = CGPointZero;
		[self addChild: wBackground z:0];
		
		// Confirmation menu item (default to invisible until "Retire" is clicked)
		CCSprite *wConfirmOnItem = [CCSprite spriteWithSpriteFrameName:@"game-menu-bar-on.png"];
		CCSprite *wConfirmOffItem = [CCSprite spriteWithSpriteFrameName:@"game-menu-bar-off.png"];
		
		mConfirm = [CCMenuItemImage
					itemFromNormalSprite:wConfirmOffItem 
					selectedSprite:wConfirmOnItem 
					target:self 
					selector:@selector(menuButtonTapped:)];
        mConfirm.visible = NO;
		
        
        // Get the game layer for various functions, such as getting number of lives
        GameLayer* wGameLayer = (GameLayer*)[CCDirector sharedDirector].runningScene;
        GamePlayLayer* wTopLayer = wGameLayer.playLayer;
        
        
		// Retire menu item
		CCSprite *wRetireOnItem = [CCSprite spriteWithSpriteFrameName:@"game-menu-bar-on.png"];
		CCSprite *wRetireOffItem = [CCSprite spriteWithSpriteFrameName:@"game-menu-bar-off.png"];
        
		mRetire = [CCMenuItemImage 
				   itemFromNormalSprite:wRetireOffItem 
				   selectedSprite:wRetireOnItem 
				   target:self 
				   selector:@selector(menuButtonTapped:)];
        // Don't bother displaying it if the lives are zero
        if(wTopLayer.ownElevator.lives == 0)
            mRetire.visible = NO;
        
        
		// Continue menu item
		CCSprite *wContinueOnItem = [CCSprite spriteWithSpriteFrameName:@"game-menu-bar-on.png"];
		CCSprite *wContinueOffItem = [CCSprite spriteWithSpriteFrameName:@"game-menu-bar-off.png"];
        
		mContinue = [CCMenuItemImage
					 itemFromNormalSprite:wContinueOffItem
					 selectedSprite:wContinueOnItem 
					 target:self 
					 selector:@selector(menuButtonTapped:)];
        

        // Tutorial menu item (only displayed if the tutorial has been fully viewed)
        CCSprite *wTutorialOnItem = [CCSprite spriteWithSpriteFrameName:@"game-menu-bar-on.png"];
        CCSprite *wTutorialOffItem = [CCSprite spriteWithSpriteFrameName:@"game-menu-bar-off.png"];
        
        mTutorial = [CCMenuItemImage
                     itemFromNormalSprite:wTutorialOffItem
                     selectedSprite:wTutorialOnItem 
                     target:self 
                     selector:@selector(menuButtonTapped:)];
        
        // Tutorial has been viewed so re-enable
        mMainMenu = [CCMenu menuWithItems:mConfirm, mRetire, mTutorial, mContinue, nil];
        [mMainMenu alignItemsVerticallyWithPadding:-0.5f];
        mMainMenu.position = ccp(120, 80); // (Four menu items = 320 x 160, so move up the menu group by 80 pixels)
        [self addChild:mMainMenu z:100];

		
		// Set the offset for main menu text (all items are same height so just use the play menu item)
		CGPoint wOffset = ccp(46, mContinue.contentSize.height / 2.0f);
		
		// Menu text (use Localizable.strings, the default table name)
		// Imported as font size 28 (DroidSans Bold)
		CCLabelBMFont *wConfirmLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"PAUSE_CONFIRM", nil) fntFile:[GameController selectFont:kDroidSansBold28White]];
		[mConfirm addChild:wConfirmLabel z:4 tag:100];
		wConfirmLabel.anchorPoint = CGPointMake(0.0f, 0.5f);
		wConfirmLabel.position = wOffset;
		
		CCLabelBMFont *wRetireLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"PAUSE_RETIRE", nil) fntFile:[GameController selectFont:kDroidSansBold28White]];
		[mRetire addChild:wRetireLabel z:4 tag:200];
		wRetireLabel.anchorPoint = CGPointMake(0.0f, 0.5f);
		wRetireLabel.position = wOffset;
		
		CCLabelBMFont *wContinueLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"PAUSE_CONTINUE", nil) fntFile:[GameController selectFont:kDroidSansBold28White]];
		[mContinue addChild:wContinueLabel z:4 tag:300];
		wContinueLabel.anchorPoint = CGPointMake(0.0f, 0.5f);
		wContinueLabel.position = wOffset;
        
        CCLabelBMFont *wTutorialLabel = [CCLabelBMFont labelWithString:NSLocalizedString(@"TUTORIAL_MENU", nil) fntFile:[GameController selectFont:kDroidSansBold28White]];
        [mTutorial addChild:wTutorialLabel z:4 tag:400];
        wTutorialLabel.anchorPoint = CGPointMake(0.0f, 0.5f);
        wTutorialLabel.position = wOffset;
        
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;    
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
	[super dealloc];
}

- (void)menuButtonTapped:(id)sender 
{
	CCMenuItem *wItem = (CCMenuItem *)sender;
    
    GameLayer* wGameLayer = (GameLayer*)[CCDirector sharedDirector].runningScene;
    GamePlayLayer* wTopLayer = wGameLayer.playLayer;
    
	if (wItem == mContinue) 
	{
        [[GameController sharedInstance] pause:NO];
	}
    
    if(wItem == mRetire)
    {
        [[AudioController sharedInstance] playSound:kClickMenuButton];
        mConfirm.visible = !mConfirm.visible;
    }
    
    if((wItem == mTutorial) && (mTutorial.isEnabled))
    {
        [[AudioController sharedInstance] playSound:kClickMenuButton];
        [GameController sharedInstance].tutorialViewed = NO;
        
        [mTutorial setIsEnabled:NO];
        CCMenuItemImage *wImage = (CCMenuItemImage*)wItem;
        wImage.scaleY = 0.0f;
        [mMainMenu alignItemsVerticallyWithPadding:-0.5f];
        mMainMenu.position = ccp(120, 60); // (Three menu items = 320 x 120, so move up the menu group by 60 pixels)
        // Mark tutorial as not viewed and show tips from the beginning
        [wTopLayer removeAllTips:NO];
        [wTopLayer startupTips];
    }
	
	if(wItem == mConfirm)
	{
        [[AudioController sharedInstance] playSound:kClickMenuButton];
        
        [[GameController sharedInstance] pause:NO];

        [wTopLayer clearPauseMenu];
        
        [[AudioController sharedInstance] musicOff];
        float wPension = wGameLayer.controlLayer.status.pension;
        [[CCDirector sharedDirector] 
		 replaceScene:[CCTransitionMoveInB
                       transitionWithDuration:TRANSITION_DURATION 
                       scene:[GameOverLayer 
                              gameOver:wPension
                              withLevel:[GameLevelMaker sharedInstance].level]]];
	}
}

/**
 * Function is called when the layer is out of view and should be removed from 
 * the parent object.
 */
-(void) pauseCleanup
{
    [mConfirm unschedule:@selector(menuButtonTapped:)];
	[mRetire unschedule:@selector(menuButtonTapped:)];
	[mContinue unschedule:@selector(menuButtonTapped:)];
    [self removeFromParentAndCleanup:YES];
}

@end
