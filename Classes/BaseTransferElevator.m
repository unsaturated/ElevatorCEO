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

#import "BaseTransferElevator.h"

@implementation BaseTransferElevator

-(id) init
{
	if( (self=[super init] )) 
	{
		mFloorRangeMin = mFloorRangeMax = 0;
		mOwnElevator = NULL;
		mDisplayingBonus = NO;
	}
	
	return self;
}

- (void) onExit
{
	[self unscheduleSelectors];
}

-(void) setOwnElevator:(OwnGameElevator*)elevator
{
	mOwnElevator = elevator;	
}

-(void) moveTo:(UInt16)floor
{
	[self moveTo:floor overrideMinMax:NO];
}

-(void) moveTo:(UInt16)floor overrideMinMax:(BOOL)ovr
{
	BOOL wGoodFloor = ( ((floor >= mFloorMin) && (floor <= mFloorMax)) || ovr );
	
	if( wGoodFloor && (floor != mFloorGoingTo) )
	{
		mFloorGoingTo = floor;
		mFloorGoingToY = (floor - mFloorMin) * FLOOR_HEIGHT - FLOOR_BOTTOM_GAP;
		mReachedFloor = NO;
		mInTransit = YES;

		BOOL wGoingDown = floor < mFloor;
		[self moveSpeed:[GameLevelMaker sharedInstance].elevatorSpeed withTap:NO directionDown:wGoingDown];
	}
}

-(void) setTo:(UInt16)floor
{
	mShouldComeToRest = NO;
	mComingToRest = NO;
	mMovementDir = kStopped;
	self.position = ccp(self.position.x, FLOOR_HEIGHT * (floor - mFloorMin)); 
	
	UInt16 wNewFloor = truncf(self.position.y / FLOOR_HEIGHT) + mFloorMin;
	
	if(wNewFloor != mFloor)
	{
		mPrevFloor = mFloor;
		mFloor = wNewFloor;
	}
}

-(void) setFloorMin:(UInt16)minValue max:(UInt16)maxValue
{
	mFloorMin = minValue;
	mFloorMax = maxValue;
	
	mTopFloorBottomY = mFloorMax * FLOOR_HEIGHT;
	mBtmFloorBottomY = 0.0f;
}

@synthesize reachedFloor = mReachedFloor;

@synthesize inTransit = mInTransit;

-(void) setActiveInGame:(BOOL)value
{
	mActiveInGame = value;
	mBalloon.visible = value;
	self.visible = mActiveInGame;
}

-(BOOL) activeInGame
{
	return mActiveInGame; 
}

-(void) moveSpeed:(UInt8)speed withTap:(BOOL)tap directionDown:(BOOL)down
{
	if(speed > 0)
	{
		// If speed is set explicitly (by the gamer) then bouncing needs to stop
		[self stopAllActions];
		if(down) 
		{
			mMove = ccp(0,  -(speed * FLOOR_HEIGHT));
			mMovementDir = kDown;
		}
		else
		{
			mMove = ccp(0,  (speed * FLOOR_HEIGHT));
			mMovementDir = kUp;
		}
	}
	else 
	{
		mMove = CGPointZero;
		mMovementDir = kStopped;
	}
	
	// If the speed was something & is now zero, then bounce to rest
	if( (mSpeed > 0) && (speed == 0) )
		mShouldComeToRest = YES;
	else
		mShouldComeToRest = NO;
	
	mSpeed = speed;
	mGoingDown = down;
}

-(void) update: (ccTime) dt
{
	// Keep track of the time spent at the current floor
	if(!mInTransit && !mDisplayingBonus)
	{
		mTimeAtFloor += dt;
		if(mPassengersOnboard > 0)
		{
			float wMaxTime = self.isCeoElevator ? [GameLevelMaker sharedInstance].stopTimeByCEO : [GameLevelMaker sharedInstance].stopTime;
			float wPercentRemain = (wMaxTime - mTimeAtFloor) / wMaxTime * 100.0f;
			[mTimerIndicator setPercent:wPercentRemain];
		}
		else
		{
			mTimerIndicator.visible = NO;
		}
	}
	else
		mTimeAtFloor = 0.0f;
	
	// Distance = rate * time
	CGPoint wMoveDist = ccpMult(mMove, dt);
	
	// Setup logic to test for movement
	float wMoveDiff = 0.0f;
	
	if(!ccpFuzzyEqual(self.position, mPrevPosition, 0.50f))
	{
		wMoveDiff = self.position.y - mPrevPosition.y;
		mPrevPosition = self.position;
	}
	
	CGPoint wNewPos;
	
	// Speed can be set manually or via implicit movement
	if(mSpeed > 0)
		wNewPos = ccpAdd(self.position, wMoveDist);
	else
	{
		mMove = ccp(0.0f, wMoveDiff);
		wNewPos = ccpAdd(self.position, wMoveDist);
	}
	
	BOOL wFloorLayerAtMax = (wNewPos.y >= mTopFloorBottomY + self.halfCarHeight);
	BOOL wFloorLayerAtMin = (wNewPos.y <= mBtmFloorBottomY + self.halfCarHeight);
	
	if(wFloorLayerAtMax)
	{
		self.position = ccp(self.position.x, mTopFloorBottomY + self.halfCarHeight);
		[self stopBounce];
	}
	else if(wFloorLayerAtMin)
	{
		self.position = ccp(self.position.x, mBtmFloorBottomY + self.halfCarHeight);
		[self stopBounce];
	}
	else
	{
		// Otherwise update the position of the elevator to the new position
		self.position = wNewPos;
	}
	
	UInt16 wNewFloor = truncf(self.position.y / FLOOR_HEIGHT) + mFloorMin;
	
	if(wNewFloor != mFloor)
	{
		mPrevFloor = mFloor;
		mFloor = wNewFloor;
	}
	
	// Stop at the destination floor
	if( (mFloor == mFloorGoingTo) && (mSpeed != 0) )
	{
		mShouldComeToRest = YES;
		mMovementDir = kStopping;
	}
		
	
	// Calculate where the elevator should stop and then bounch to rest
	// If set to FLOOR_HEIGHT (and because the elevator position is according to the center
	// of the car) 
	float wFloorTestBuffer = (mMove.y < 0.0f) ? (FLOOR_HEIGHT / 4.0f) : (FLOOR_HEIGHT / 1.5f);
	if(ccpFuzzyEqual(self.position, ccp(self.position.x, mFloorGoingToY + wFloorTestBuffer), 0.5f))
	{
		mShouldComeToRest = YES;
		mMovementDir = kStopping;
	}
	
	// The elevator SHOULD come to rest, but is not already
	if(mShouldComeToRest && !mComingToRest)
	{
		CGPoint wAdjPos = ccp(self.position.x, mFloorGoingToY + (FLOOR_HEIGHT / 2.0f));
        
		mComingToRest = YES;
		mMovementDir = kStopping;
		
		// Remember : Distances are reversed for the floor layer since it moves in the 
		// opposite direction of the elevator.
		
		// run action to move the elevator itself
		[self runAction:[CCSequence actionOne:
						 [CCEaseBounceOut actionWithAction: 
						  [CCMoveTo actionWithDuration:ELEVATOR_SETTLE_TIME position:wAdjPos]]
										  two:[CCCallFunc 
											   actionWithTarget:self 
											   selector:@selector(stopBounce)]]];
	}
}

-(void) stopBounce
{
	//[self moveSpeed:0 withTap:NO directionDown:NO];
    mSpeed = 0;
    mMove = ccp(0, 0);
    mMovementDir = kStopped;
    
	mShouldComeToRest = NO;
	mComingToRest = NO;
	mInTransit = NO;
	mReachedFloor = YES;
}

-(void) setBonus:(Bonus)b
{
	mBonus = b;
	// Hide the passenger if there's a bonus, in which case the first frame
	// of the treasure chest animation should be shown
	if(mBonus == kNone)
	{
		mLabelPassengers.visible = YES;
		mChestAnimation.visible = NO;
	}
	else
	{
		mLabelPassengers.visible = NO;
		mChestAnimation.visible = YES;
        [mChestAnimation setDisplayFrameWithAnimationName:@"Chest" index:0];
        mChestAnimation.opacity = 255;
				
		// Get a new bonus sprite and add if not nil (not every bonus has an associated image), get from cache
		NSString* wStr = [[GameLevelMaker sharedInstance] getBonusSprite:mBonus];
		
		if(wStr != nil)
		{
			mBonusSprite.visible = NO;
			[mBonusSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:wStr]];
		}
	}
}

-(void) setFloorRangeMin:(UInt16)min maximum:(UInt16)max
{
	mFloorRangeMin = min;
	mFloorRangeMax = max;
}

@synthesize floorRangeMin = mFloorRangeMin;

@synthesize floorRangeMax = mFloorRangeMax;

@synthesize timeAtFloor = mTimeAtFloor;

-(void) touched
{	
	// If this elevator is on the same floor as the Own Elevator, then...
	// - Animate treasure chest
	// - Display bonus
	// - Take action according to bonus
	// - Animate poof
    
    // Ignore during pause
    if([GameController sharedInstance].isPaused)
        return;
    
    // Escape early
    if(mTouched)
        return;
    
	if(mOwnElevator != NULL)
	{
		if( (self.floor == mOwnElevator.floor) && (!self.inTransit) )
		{
            // Only allow the elevator to be touched once
            mTouched = YES;
            
			if(mBonus == kNone)
			{
				// if not a bonus and just a normal passenger count
				[mOwnElevator removePassengers:self.passengersOnboard ceo:NO];
				mBalloon.visible = NO;
				mLabelPassengers.visible = NO;
				
                float wPensionBump = self.passengersOnboard * TRANSFER_VALUE;
                float wSynergyBump = self.passengersOnboard * SYNERGY_BUMP;
                [self animatePension:wPensionBump];
				[mOwnElevator.controlLayer.status changePensionBy:wPensionBump];
                [mOwnElevator.controlLayer.status changeSynergyBy:wSynergyBump];

				mPassengersOnboard = 0;
                
                // Animate poof and play sound
                
                [[AudioController sharedInstance] playSound:kPassengerBonus];
				
				CCAnimate* wPoof = [CCSequence actions:
									[CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"Poof"]],
									[CCHide action],
									nil];
				[mPoofAnimation runAction:wPoof];	
			}
			else
			{
				// BONUS! Animate the treasure chest, display bonus, then invoke relevant notification
				mDisplayingBonus = YES;
				
				CCAction* wBonus = [CCSequence actions:
									[CCShow action],
									[CCFadeIn actionWithDuration:0.5f],
									[CCDelayTime actionWithDuration:1.0f],
									[CCHide action],
									[CCCallFunc actionWithTarget:self selector:@selector(bonusAnimationComplete)],
									nil];
				
				id wBonusTarget = nil;
				
				if(mBonus != kPassenger)
					wBonusTarget = mBonusSprite;
				else
					wBonusTarget = mLabelPassengers;

				CCAnimate* wTreasureChest = [CCSequence actions:
											 [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"Chest"] restoreOriginalFrame:NO],
											 [CCFadeOut actionWithDuration:0.5f],
											 [CCCallFuncO actionWithTarget:wBonusTarget selector:@selector(runAction:) object:wBonus],
											 nil];		

                [[AudioController sharedInstance] playSound:kTreasureChestOpening];
				[mChestAnimation runAction:wTreasureChest];
			}
		}
	}
}

-(void) initializeLevel
{
    // Reset the touched status
    mTouched = NO;
    mMove = mPrevPosition = CGPointZero;
    mReachedFloor = NO;
    mInTransit = NO;
    mFloorGoingToY = 0.0f;
    mFloorRangeMin = mFloorRangeMax = 0;
    mFloor = mFloorGoingTo = 0;
    mTimeAtFloor = 0.0f;
    mFloorMin = mFloorMax = 0;
    mMovementDir = kStopped;
    mPoofAnimation.visible = YES;
    mTimerIndicator.visible = YES;
}

-(void) bonusAnimationComplete
{
	mDisplayingBonus = NO;
	CCAnimate* wPoof = [CCSequence actions:
						[CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"Poof"]],
						[CCHide action],
						nil];
	
	// Trigger an appropriate bonus action
	switch(mBonus)
	{
		case kNone:
			break;
		case kHeart:
            [[AudioController sharedInstance] playSound:kLifeBonus];
			[mOwnElevator setLives:(mOwnElevator.lives + 1)];
			 break;
		case kPension:
            [[AudioController sharedInstance] playSound:kPensionBonus];
			[mOwnElevator.controlLayer.status changePensionBy:[[GameLevelMaker sharedInstance] getBonusValue:mBonus]];
			 break;
		case kDeath:
			[mOwnElevator setLives:(mOwnElevator.lives - 1)];
			break;
		case kPassenger:
            [[AudioController sharedInstance] playSound:kPassengerBonus];
			[mOwnElevator removePassengers:self.passengersOnboard];
			mBalloon.visible = NO;
			mLabelPassengers.visible = NO;
			[mOwnElevator.controlLayer.status changePensionBy:(self.passengersOnboard * TRANSFER_VALUE)];
			break;
		case kNoRadar:
            [[AudioController sharedInstance] playSound:kNoRadarBonus];
			[mOwnElevator.controlLayer.radar hideRadarForFloors:[[GameLevelMaker sharedInstance] getBonusValue:mBonus]];
			break;
		case kSynergy:
            [[AudioController sharedInstance] playSound:kSynergyBonus];
			[mOwnElevator setSynergy:(mOwnElevator.synergy + (float)[[GameLevelMaker sharedInstance] getBonusValue:mBonus])];
			break;
	}
	
	// Clear away the bonus sprites
	mPassengersOnboard = 0;
	[mPoofAnimation runAction:wPoof];
	mBalloon.visible = NO;
	mBonusSprite.visible = NO;
	mLabelPassengers.visible = NO;
}

-(void) unscheduleSelectors
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

@end
