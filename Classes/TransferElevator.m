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

#import "TransferElevator.h"

@implementation TransferElevator

-(id) init
{
	if( (self=[super init] )) 
	{
        mHandlingTouches = NO;
		
		mCar = [CCSprite spriteWithSpriteFrameName:@"el-green-game.png"];
		mCar.position = ccp(0, 0);
		[self addChild: mCar z:2];
		
		// This is the main game play elevator
		mIsOwnElevator = NO;
		
		// We want to set the position manually
		[self scheduleUpdate];
		
		self.visible = YES;
		
		mSpeed = 0;
		mGoingDown = NO;
		
		mPrevFloor = 0;
		
		// Used for controlling bouncing effect
		mShouldComeToRest = NO;
		mComingToRest = NO;
		mInTransit = NO;
		mActiveInGame = NO;
		
		mBonus = kNone;
		
		mTimeAtFloor = 0.0f;
		
		mFloorGoingTo = 0;
		
		mTopFloorBottomY = mBtmFloorBottomY = mFloorGoingToY = 0;
		
		self.position = ccp(0, self.halfCarHeight);
		mPrevPosition = self.position;
		
		mBalloon = [CCSprite spriteWithSpriteFrameName:@"dialog.png"];
		mBalloon.position = ccp(self.position.x, self.position.y * 2.0f);
		[self addChild:mBalloon z:3];
		
		mPoofAnimation = [CCSprite node];
		mPoofAnimation.position = ccp(self.position.x, self.position.y * 2.0f);
		[self addChild:mPoofAnimation z:12];
		
		mLabelPassengers = [CCLabelBMFont labelWithString:@"0" fntFile:[GameController selectFont:kDroidSansBold20Black forceDefault:YES]];
		mLabelPassengers.position = ccp(self.position.x, self.position.y * 2.0f);
		mLabelPassengers.visible = NO;
		[self addChild:mLabelPassengers z:4];
		
		// Bonus sprite is set in the base class in the setBonus function
		mBonusSprite = [CCSprite node];
		mBonusSprite.position = ccp(self.position.x + 1.0f, self.position.y * 2.0f + 1.0f);
		[self addChild:mBonusSprite z:10];
		
		mChestAnimation = [CCSprite node];
		[mChestAnimation setDisplayFrameWithAnimationName:@"Chest" index:0];
		mChestAnimation.position = ccp(self.position.x + 1.0f, self.position.y * 2.0f + 1.0f);
		mChestAnimation.visible = NO;
		[self addChild:mChestAnimation z:7];
		
		mTimerIndicator = [ElevatorTimer node];
		mTimerIndicator.position = ccp((mCar.contentSize.width / 2.0f - mTimerIndicator.contentSize.width / 2.0f), 6.0f);
		[mCar addChild:mTimerIndicator z:5];
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

-(void) dealloc
{
    if (mHandlingTouches)
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    CCLOG(@"---DEALLOC %@", self);
    [super dealloc];
}

-(void) setActiveInGame:(BOOL)activeInGame
{
    if(activeInGame && !mHandlingTouches)
    {
        CCLOG(@"Adding elevator to touch handler.");
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
        mHandlingTouches = YES;
    }
    else if(!activeInGame && mHandlingTouches)
    {
        CCLOG(@"Removing elevator from touch handler.");
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
        mHandlingTouches = NO;
    }
    
    mActiveInGame = activeInGame;
    mBalloon.visible = activeInGame;
    self.visible = mActiveInGame;
}

@end
