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

// Base implementation
#import "GamePlayLayer.h"

// Dependencies
#import "OwnGameElevator.h"
#import "TransferElevator.h"
#import "CeoElevator.h"
#import "ShaftControl.h"

// Tutorial tips
#import "WelcomeTip.h"
#import "ButtonsTip.h"
#import "GreenElevatorTip.h"
#import "GoalTip.h"
#import "CeoTip.h"

@implementation GamePlayLayer

-(id) init
{
	if( (self = [super init]) )
	{
        CGRect winRect = [GameController sharedInstance].gamingAreaRect;
		CGSize winSize = winRect.size;
        mVisibleRect = winRect;
        
		// Establish properties of control layer itself
		[self setAnchorPoint:winRect.origin];
        [self setContentSize:CGSizeMake(240, winSize.height)];
        
		// Add a background color to the layer
		CCLayerColor *wColorLayer = [CCLayerColor layerWithColor: ccc4(0, 0, 0, 255) width:240 height:winSize.height];
		[self addChild: wColorLayer z:0];
		wColorLayer.isTouchEnabled = NO;
		
		mFloorLayer = [GamePlayFloorLayer node];
		[self addChild:mFloorLayer z:1];
		mFloorLayer.position = ccp(PLAY_AREA_MARGIN, 0);
	
		// Own elevator (controls the floor layer)
		mOwnElevator = [OwnGameElevator node];
		[self addChild:mOwnElevator z:2];
		mOwnElevator.position = ccp(PLAY_AREA_MARGIN + ELEVATOR_SHAFT_WIDTH / 2.0f, mOwnElevator.halfCarHeight); 
		[mOwnElevator setFloorLayer:mFloorLayer];
		
		// CEO's elevator (there can be only one!)
		mCeoElevator = [CeoElevator node];
		[mCeoElevator setOwnElevator:mOwnElevator];
		mCeoElevator.visible = NO;

		mShaft1 = [[ShaftControl alloc] init];
		[mShaft1 setOwnElevator:mOwnElevator ceoElevator:nil];
		[mShaft1 addElevatorsToNode:mFloorLayer ceoElevator:nil];
		CGPoint wPnt = ccp([GamePlayLayer locationForShaft:2], 0.0f);
		[mShaft1 setShaftLocation:wPnt];
		
		mShaft2 = [[ShaftControl alloc] init];
		[mShaft2 setOwnElevator:mOwnElevator ceoElevator:nil];
		[mShaft2 addElevatorsToNode:mFloorLayer ceoElevator:nil];
		wPnt = ccp([GamePlayLayer locationForShaft:3], 0.0f);
		[mShaft2 setShaftLocation:wPnt];

		mShaft3 = [[ShaftControl alloc] init];
		[mShaft3 setOwnElevator:mOwnElevator ceoElevator:nil];
		[mShaft3 addElevatorsToNode:mFloorLayer ceoElevator:nil];
		wPnt = ccp([GamePlayLayer locationForShaft:4], 0.0f);
		[mShaft3 setShaftLocation:wPnt];

		mShaft4 = [[ShaftControl alloc] init];
		[mShaft4 setOwnElevator:mOwnElevator ceoElevator:mCeoElevator];
		[mShaft4 addElevatorsToNode:mFloorLayer ceoElevator:mCeoElevator];
		wPnt = ccp([GamePlayLayer locationForShaft:5], 0.0f);
		[mShaft4 setShaftLocation:wPnt];
        
        // The CEO needs to provide access to the shaft
        mCeoElevator.shaft = mShaft4;
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

-(void) visit
{
    [self preVisitWithClippingRect:mVisibleRect];
    [super visit];
    [self postVisit];
}

-(void) initializeWithLevel
{
	GameLevelMaker* wMaker = [GameLevelMaker sharedInstance];
	
	GameLevelTransition* wTrans = [GameLevelTransition 
								   transitionWithLevel: wMaker.level
								   floorMin:wMaker.startFloor 
								   floorMax:wMaker.stopFloor];
    
    [mOwnElevator.controlLayer.radar.contents runAction:
     [CCSequence 
      actions:
      [CCHide action],
      [CCDelayTime actionWithDuration:TRANSITION_LAYER_DISPLAY_SEC],
      [CCBlink actionWithDuration:RADAR_INDICATOR_BLINK_TIME blinks:NUM_BLINKS_RADAR_HIDDEN],
      [CCShow action],
      nil]];
	
	[self addChild:wTrans z:100 tag:100];
	wTrans.position = ccp(PLAY_AREA_MARGIN, 0);
	[wTrans showTransition];
    
    // Display the tutorial tips if it's level 1 and 
    // the tips haven't previously been shown
    if( (wMaker.level == 1) && ![GameController sharedInstance].tutorialViewed)
    {
        // Clean up any previous tips (maybe a life is lost on level 1) and then display all tips anew
        [self removeAllTips:NO];
        [self runAction:[CCSequence 
                         actionOne:[CCDelayTime actionWithDuration:TUTORIAL_DISPLAY_DELAY_SEC] 
                         two:[CCCallFunc actionWithTarget:self selector:@selector(startupTips)]]];
    }
    else if(wMaker.level == 2) 
    {
        // Clean up all the tips because the player already leveled-up! No need to nag them anymore.
        [self removeAllTips:YES];
    }
    
    // Setup the own elevator
    [mOwnElevator initializeLevel];
}

-(void) showPauseMenu
{
    GamePauseLayer* wPause = [GamePauseLayer node];
    [self addChild:wPause z:300 tag:300];
    wPause.position = ccp(PLAY_AREA_MARGIN-1, 0);
}

-(void) clearPauseMenu
{
    [self removeChildByTag:300 cleanup:YES];
}

-(void)setGameControlLayer:(GameControlLayer*)layer
{
    mControlLayer = layer;
	[mOwnElevator setGameControlLayer:layer];
    mOwnElevator.playLayer = self;
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
	[super dealloc];
}

- (void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
}

- (void) onExit
{
	[super onExit];
}
		 
-(void) moveFloorSpeed:(BOOL)oneFloor withSpeed:(UInt8) speed directionDown:(BOOL)down
{
	[mOwnElevator moveSpeed:speed withTap:oneFloor directionDown:down];
}

-(void) setFloorMinimum:(UInt16)min maximum:(UInt16)max
{
	[mFloorLayer setFloorMin:min max:max];
}

-(void) showTip:(BaseTutorialTip *)tip
{
    CGRect winSize = [[GameController sharedInstance] gamingAreaRectForPlay:YES];
    [tip setAnchorPoint:CGPointMake(0, 1)];
    [self addChild:tip z:100];
    tip.position = ccp(PLAY_AREA_MARGIN, winSize.size.height + tip.contentSize.height);
    [tip showTip];
}

-(void) startupTips
{
    [self showTip:[WelcomeTip node]];
}

-(void) removeAllTips:(BOOL)tutorialViewed
{
    CCArray* removeArray = [CCArray array];
    CCNode* child;
    CCARRAY_FOREACH(self.children, child)
    {
        // Find only the children that derive from BaseTutorialTip
        if([child.class isSubclassOfClass:[BaseTutorialTip class]])
        {
            BaseTutorialTip* tip = (BaseTutorialTip*)child;
            [removeArray addObject:tip];
        }
    }
    
    BaseTutorialTip* removeTip;
    CCARRAY_FOREACH(removeArray, removeTip)
    {
        // Immediately remove the tips without any animation
        [removeTip exitTip:YES];
    }

    [GameController sharedInstance].tutorialViewed = tutorialViewed;
}

@synthesize ownElevator = mOwnElevator;

@synthesize ceoElevator = mCeoElevator;

@synthesize floorLayer = mFloorLayer;

@synthesize transferShaft1 = mShaft1;

@synthesize transferShaft2 = mShaft2;

@synthesize transferShaft3 = mShaft3;

@synthesize transferShaft4 = mShaft4;

+(float) locationForShaft:(UInt8) number
{
	return (ELEVATOR_SHAFT_WIDTH / 2.0f) + (number - 1) * ELEVATOR_SHAFT_WIDTH;
}

@end
