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

#import "OwnGameElevator.h"
#import "GameLevelMaker.h"
#import "CeoTip.h"

@implementation OwnGameElevator

-(id) init
{
	if( (self=[super init] )) 
	{
		// The blue elevator is the smallest
		mCar = [CCSprite spriteWithSpriteFrameName:@"el-blue-game.png"];
		mCar.position = CGPointZero;
		[self addChild: mCar z:2];
		
		// Passenger balloon indicator
		mBalloon = [CCSprite spriteWithSpriteFrameName:@"dialog.png"];
		mBalloon.position = ccp(self.position.x, mCar.contentSize.height);
		[self addChild:mBalloon z:3];
		
		mLabelPassengers = [CCLabelBMFont labelWithString:@"0" fntFile:[GameController selectFont:kDroidSansBold20Black forceDefault:YES]];
		mLabelPassengers.position = ccp(mBalloon.contentSize.width / 2.0f, mBalloon.contentSize.height / 2.0f);
		[mBalloon addChild:mLabelPassengers z:4];
		
		// Death elevator is just a sprite and since controlling actual Own Elevator
		// would cause other problems, just use a separate sprite
		mDeathElevator = [CCSprite spriteWithSpriteFrameName:@"el-black-game.png"];
		mDeathElevator.position = CGPointZero;
		mDeathElevator.visible = NO;
		[self addChild:mDeathElevator z:20];
		
		// This is the main game play elevator
		mIsOwnElevator = YES;
		
		// We want to set the position manually
		[self scheduleUpdate];
		
		self.visible = YES;
		
		// Establish up/down scroll points based upon the aspect ratio (iPhone 5)
        if([GameController sharedInstance].is16x9)
        {
            mUpScrollPoint = BEGIN_SCROLL_UP_ON_FLOOR_16x9 * FLOOR_HEIGHT;
            mDnScrollPoint = BEGIN_SCROLL_DOWN_ON_FLOOR_16x9 * FLOOR_HEIGHT;
            mFloorsPerScreen = FLOORS_PER_SCREEN_16x9;
        }
        else
        {
            mUpScrollPoint = BEGIN_SCROLL_UP_ON_FLOOR * FLOOR_HEIGHT;
            mDnScrollPoint = BEGIN_SCROLL_DOWN_ON_FLOOR * FLOOR_HEIGHT;
            mFloorsPerScreen = FLOORS_PER_SCREEN;
        }
		
		mSpeed = 0;
		mGoingDown = NO;
		
		mPrevFloor = 0;

		// Used for controlling bouncing effect
		mShouldComeToRest = NO;
		mComingToRest = NO;
		
		self.position = ccp(0, self.halfCarHeight);
		
		mPrevPosition = self.position;
		
		mTapDistance = 0.0f;
		mTapped = NO;
		
		mSynergy = STARTING_SYNERGY;
		mLives = GAME_STARTING_LIVES;
        
        mMovedToCeoElevator = NO;
		
		mDeathSequencePlaying = NO;
        
        mSynergyDeathSequencePlaying = NO;
        
        levelUpPlaying = NO;
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}


- (void) dealloc
{
	[mFloorLayer release];
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

-(void) removePassengers:(UInt8)passengers
{
	mPassengersOnboard = MAX(mPassengersOnboard - passengers, 0);
	[mLabelPassengers setString:[[NSNumber numberWithChar:mPassengersOnboard] stringValue]];
	if(mPassengersOnboard == 0)
		[self setLives:(mLives - 1)];
    else 
    {
        if(mPassengersOnboard == 1)
        {
            // Display the CEO tutorial tip if applicable
            if(![GameController sharedInstance].tutorialViewed)
            {
                // Remove all previous tips but don't consider the tutorial viewed until this one is touched
                [self.playLayer removeAllTips:NO];
                [self.playLayer showTip:[CeoTip lastTip:YES]];
            }
        }
    }
}

- (void) moveTo:(UInt16)floor
{
	mFloorGoingTo = floor;
}

-(void) moveSpeed:(UInt8)speed withTap:(BOOL)tap directionDown:(BOOL)down
{	
	// Ignore input until the tap is satisfied or death sequence is complete
	if( (mTapped && tap) || mComingToRest || mDeathSequencePlaying || mSynergyDeathSequencePlaying)
		return;
    
    // Ignore input since we moved to the CEO's elevator
    if(mMovedToCeoElevator)
        return;
	
	// Assign temp speed
	UInt8 wTempSpeed = 0;
	if(tap && !mTapped)
		wTempSpeed = SPEED_FOR_BUTTON_TAP;
	else if(tap && mTapped)
		wTempSpeed = SPEED_FOR_BUTTON_TAP;
	else
		wTempSpeed = speed;
	
	// Handle tap logic
	if(tap && !mTapped)
	{
		UInt16 wCurFloor = [mFloorLayer floorFromPosition:self.position];
		
		if( (wCurFloor-1 >= mFloorMin) || (wCurFloor+1 <= mFloorMax) )
		{
			UInt16 wDesiredFloor = down ? (wCurFloor - 1) : (wCurFloor + 1);
			CGPoint wAdjPos = ccp(self.position.x, self.position.y - self.halfCarHeight);
			float wDist = [mFloorLayer distanceToFloorBtm:wDesiredFloor atPosition:wAdjPos];
			// The value is always positive because direction is built into the speed request.
			mTapDistance = down ? POSITIVEF(wDist - 5.0f) : POSITIVEF(wDist + 5.0f);
			CCLOG(@"On floor %d, moving %d w/ distance %f", wCurFloor, wDesiredFloor, mTapDistance);
			mTapped = YES;
		}
	}
	else if(tap && mTapped)
	{
		// Do nothing
	}
	else if(!tap)
	{
        [[AudioController sharedInstance] playSound:kElevatorMoving];
		mTapped = NO;
		mTapDistance = -15.0f;
	}

	if(wTempSpeed > 0 && mTapped)
	{
		CCLOG(@"STOPPING ALL ACTIONS for tap");
		if(down) 
		{
			mMove = ccp(0,  -(wTempSpeed * FLOOR_HEIGHT));
			mMovementDir = kDown;
		}
		else
		{
			mMove = ccp(0,  (wTempSpeed * FLOOR_HEIGHT));
			mMovementDir = kUp;
		}
	} else if(wTempSpeed > 0 && !mTapped)
	{
		CCLOG(@"STOPPING ALL ACTIONS for no-tap");
		if(down) 
		{
			mMove = ccp(0,  -(wTempSpeed * FLOOR_HEIGHT));
			mMovementDir = kDown;
		}
			
		else
		{
			mMove = ccp(0,  (wTempSpeed * FLOOR_HEIGHT));
			mMovementDir = kUp;
		}
			
	}
	else 
	{
		mMove = CGPointZero;
		mMovementDir = kStopped;
	}
	
	// If the speed was something & is now zero, then bounce to rest
	if( (mSpeed > 0) && (wTempSpeed == 0) )
	{
		CCLOG(@"SHOULD COME TO REST!");
		mShouldComeToRest = YES;
		mMovementDir = kStopping;
        [[AudioController sharedInstance] stopSound:kElevatorMoving];
        [[AudioController sharedInstance] playSound:kElevatorStopping];	
    }
	else
		mShouldComeToRest = NO;

	mSpeed = wTempSpeed;
	mGoingDown = down;
}

-(void) update: (ccTime) dt
{	
	// Distance = rate * time
	CGPoint wMoveDist = ccpMult(mMove, dt);
	
	// Setup logic to test for movement
	float wMoveDiff = 0.0f;
	
	if(!ccpFuzzyEqual(self.position, mPrevPosition, 0.50f))
	{
		wMoveDiff = self.position.y - mPrevPosition.y;
		mPrevPosition = self.position;
	}
	
	UInt16 wCurFloor = [mFloorLayer floorFromPosition:self.position];
    
    // THIS IS AN ERROR CONDITION!
    if(wCurFloor == 0)
        return;
    
    // Elevator has stopped, synergy is empty, but death sequence has not yet begun
    if(mSynergyDeathSequencePlaying && !mDeathSequencePlaying)
    {
        [self removePassengers:self.passengersOnboard];
    }
    
	if(wCurFloor != mPrevFloor)
	{
        mAtTopFloor = (wCurFloor == mFloorMax);
        mAtBottomFloor = (wCurFloor == mFloorMin);
        
		mPrevFloor = wCurFloor;
		mFloor = wCurFloor;
		
		// Decrement the available synergy
		mSynergy -= ((100.0f / [GameLevelMaker sharedInstance].floors) * SYNERGY_PER_FLOOR);
        
        // When synergy is depleted, just get rid of all the passengers and the death 
        // sequence will handle itself
        if( (mSynergy <= 0.0f) && !mDeathSequencePlaying)
        {
            mSynergyDeathSequencePlaying = YES;
            
       
            // The current tap state is important; it means the elevator 
            // will settle at the next floor as desired and should automatically
            // change to the death elevator appearance
            if(mTapped)
            {
                mShouldComeToRest = YES;
                mTapDistance = -1.0f;
            }
            else
            {
                // Very likely the elevator is in motion, so settle to one floor
                // above or below current floor, based upon the direction of movement
                if(self.movementDir == kDown)
                {
                    [self moveSpeed:0 withTap:YES directionDown:YES];
                }
                else if(self.movementDir == kUp)
                {
                    [self moveSpeed:0 withTap:YES directionDown:NO];
                }
            }
        }
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
	
	// Check if button was tapped 
	if(mTapped)
	{
		// Check if distance needed to travel is still valid
		if(mTapDistance > 0.0f)
		{
			// Adjust distance remaining
			mTapDistance -= POSITIVEF(wMoveDist.y);
		}
		else 
		{
			mTapDistance = -1.0f;
			// Tap distance satisfied so settle to the bounce
			[self moveSpeed:0 withTap:NO directionDown:NO];
		}
	}
	
	// Whether the floor should scroll and whether the floor layer is at a min/max
	BOOL wShouldScrollUp = ((wNewPos.y + self.halfCarHeight > mUpScrollPoint) && (mMove.y > 0.0f) &&
							mFloorLayer.canElevatorMoveUp);
	BOOL wShouldScrollDn = ((wNewPos.y + self.halfCarHeight < mDnScrollPoint) && (mMove.y < 0.0f) &&
							mFloorLayer.canElevatorMoveDown);
	BOOL wFloorLayerAtMax = !mFloorLayer.canElevatorMoveUp && mFloorLayer.canElevatorMoveDown;
	BOOL wFloorLayerAtMin = !mFloorLayer.canElevatorMoveDown && mFloorLayer.canElevatorMoveUp;
	
	if(wFloorLayerAtMax)
	{
		// This means the background cannot scroll up any further and 
		// that the elevator itself has to complete the remaining 
		// distance to the top floor
		CGPoint wElMove = ccpAdd(self.position, wMoveDist);
		
		if(wElMove.y < (FLOOR_HEIGHT * (mFloorsPerScreen - 1) - self.halfCarHeight))
			wNewPos = ccpAdd(self.position, wMoveDist);
		else 
			wNewPos = ccp(self.position.x, (FLOOR_HEIGHT * (mFloorsPerScreen - 1) - self.halfCarHeight));
		
		// Set the maximum or minimum y position to the floor where scrolling should begin
		if(wShouldScrollUp)
			wNewPos = ccp(self.position.x, mUpScrollPoint);
		else if(wShouldScrollDn)
			wNewPos = ccp(self.position.x, mDnScrollPoint);
		else 
		{
			// Otherwise update the position of the elevator to the new position
			self.position = wNewPos;
		}
	}
	else if(wFloorLayerAtMin)
	{
		// This means the background cannot scroll down any further and 
		// that the elevator itself has to complete the remaining 
		// distance to the bottom floor
		CGPoint wElMove = ccpAdd(self.position, wMoveDist);
		
		if(wElMove.y > self.halfCarHeight)
			wNewPos = ccpAdd(self.position, wMoveDist);
		else 
			wNewPos = ccp(self.position.x, self.halfCarHeight);
		
		// Set the maximum or minimum y position to the floor where scrolling should begin
		if(wShouldScrollUp)
			wNewPos = ccp(self.position.x, mUpScrollPoint);
		else if(wShouldScrollDn)
			wNewPos = ccp(self.position.x, mDnScrollPoint);
		else 
		{
			// Otherwise update the position of the elevator to the new position
			self.position = wNewPos;
		}
	}
	else
	{
		// Set the maximum or minimum y position to the floor where scrolling should begin
		if(wShouldScrollUp)
			wNewPos = ccp(self.position.x, mUpScrollPoint);
		else if(wShouldScrollDn)
			wNewPos = ccp(self.position.x, mDnScrollPoint);
		else 
		{
			// Otherwise update the position of the elevator to the new position
			self.position = wNewPos;
		}
	}
	
	// Scroll the floor layer if the elevator is trying to come to rest 
	// or if the speed is greater than zero; in either case, this condition 
	// is only executed if the floor should scroll up
	if( (wShouldScrollUp && mShouldComeToRest) || (wShouldScrollUp && (mSpeed > 0)) )
	{
		// The speed should be proportional to the distance it should travel
		float wCalcSpeed = POSITIVEF(mMove.y / ELEVATOR_SETTLE_TIME);
		
		// Test if the speed is not set by the gamer, calculated speed is still greater than
		// zero, and movement distance is almost zero
		if( (mSpeed == 0) && wCalcSpeed > 0.0f && !ccpFuzzyEqual(CGPointZero, wMoveDist, 0.2f))
		{
			// Get the location of the elevator's bottom
			CGPoint wAdjPos = ccp(self.position.x, self.position.y - self.halfCarHeight);
			
			if(!mComingToRest)
			{
				// Not coming to rest, so tell the floor to move at the calculated speed
				[mFloorLayer moveSpeed:wCalcSpeed directionDown:mGoingDown];	
			}
			else 
			{
				// Coming to rest, so set the floor speed to be proportional to the distance
				// it should travel
				float wDist = [mFloorLayer distanceToFloorBtm:wCurFloor atPosition:wAdjPos];
				wCalcSpeed = POSITIVEF( (wDist/2.0f) / ELEVATOR_SETTLE_TIME);
				[mFloorLayer moveSpeed:wCalcSpeed directionDown:mGoingDown];	
			}		
		}
		else
			[mFloorLayer moveSpeed:mSpeed directionDown:mGoingDown];
	} 
	// Scroll the floor layer if the elevator is trying to come to rest 
	// or if the speed is greater than zero; in either case, this condition 
	// is only executed if the floor should scroll down
	else if( (wShouldScrollDn && mShouldComeToRest) || (wShouldScrollDn && (mSpeed > 0)) )
	{
		float wCalcSpeed = POSITIVEF(mMove.y / ELEVATOR_SETTLE_TIME);
		
		if( (mSpeed == 0) && wCalcSpeed > 0.0f && !ccpFuzzyEqual(CGPointZero, wMoveDist, 0.2f))
		{
			CGPoint wAdjPos = ccp(self.position.x, self.position.y - self.halfCarHeight);
			
			if(!mComingToRest)
			{
				[mFloorLayer moveSpeed:wCalcSpeed directionDown:mGoingDown];	
			}
			else 
			{
				float wDist = [mFloorLayer distanceToFloorBtm:wCurFloor atPosition:wAdjPos];
				wCalcSpeed = POSITIVEF( (wDist/2.0f) / ELEVATOR_SETTLE_TIME);
				[mFloorLayer moveSpeed:wCalcSpeed directionDown:mGoingDown];
			}
		}
		else
		{
			[mFloorLayer moveSpeed:mSpeed directionDown:mGoingDown];
		}
	} 
	else if(mSpeed == 0)
	{
		// If the speed is zero and not coming to rest, ensure the floor is NOT moving
		[mFloorLayer moveSpeed:0 directionDown:NO];
	}
	
	// The elevator SHOULD come to rest, but is not already
	if(mShouldComeToRest && !mComingToRest)
	{
		CGPoint wAdjPos = ccp(self.position.x, self.position.y - self.halfCarHeight);
		float wDist = [mFloorLayer distanceToFloorBtm:wCurFloor atPosition:wAdjPos];
		
		CCLOG(@"Should rest / not coming to rest: dist = %f", wDist);
		
		// Ensure the max scroll point is adhered to if the floor can scroll
		if( (self.position.y > mUpScrollPoint) && mFloorLayer.canElevatorMoveUp)
		{
			self.position = ccp(self.position.x, mUpScrollPoint);
		}
		else if( (self.position.y > mUpScrollPoint) && !mFloorLayer.canElevatorMoveUp)
		{
			// Don't do anything! Let the bounce handle the difference
		}
		
		mComingToRest = YES;
		mMovementDir = kStopping;
		
		// Remember : Distances are reversed for the floor layer since it moves in the 
		// opposite direction of the elevator.
		
		// Check to see if the floors or elevator should move. If the elevator is at the
		// upper or lower scroll point, and the floors can be scrolled, then they will be.
		// Otherwise, move the elevator itself.
		
		if( (wDist + self.position.y  > mUpScrollPoint) && mFloorLayer.canElevatorMoveUp)
		{
			CCLOG(@"BOUNCING FLOOR!");
			// run action to move floors by the difference upwards
			[mFloorLayer runAction:[CCSequence actionOne:
									[CCEaseBounceOut actionWithAction: 
									 [CCMoveBy actionWithDuration:ELEVATOR_SETTLE_TIME position:ccp(0.0f,-wDist)]]
													 two:[CCCallFunc 
														  actionWithTarget:self 
														  selector:@selector(stopBounce)]]];
		}
		else if( (wDist + self.position.y < mDnScrollPoint) && mFloorLayer.canElevatorMoveDown)
		{
			CCLOG(@"BOUNCING FLOOR!");
			// run action to move floors by the difference downwards
			[mFloorLayer runAction:[CCSequence actionOne:
									[CCEaseBounceOut actionWithAction: 
									 [CCMoveBy actionWithDuration:ELEVATOR_SETTLE_TIME position:ccp(0.0f,-wDist)]]
													 two:[CCCallFunc 
														  actionWithTarget:self 
														  selector:@selector(stopBounce)]]];
		}
		else
		{
			CCLOG(@"BOUNCING ELEVATOR!");
			// run action to move the elevator itself
			[self runAction:[CCSequence actionOne:
							 [CCEaseBounceOut actionWithAction: 
							  [CCMoveBy actionWithDuration:ELEVATOR_SETTLE_TIME position:ccp(0.0f,wDist)]]
											  two:[CCCallFunc 
												   actionWithTarget:self 
												   selector:@selector(stopBounce)]]];
		}
	}
	else if(mShouldComeToRest && mComingToRest)
	{
		//CCLOG(@"Should come to rest AND coming to rest.");
	}

}

-(void) setFloorLayer:(GamePlayFloorLayer*)floor
{
	mFloorLayer = [floor retain];
}

-(void) stopBounce
{
	[self stopAllActions];
	CCLOG(@"Should NOT come to rest.");
	mShouldComeToRest = NO;
	mComingToRest = NO;
}

-(void) initializeLevel
{
    self.levelUpPlaying = NO;
    mBalloon.visible = YES;
    mLabelPassengers.visible = YES;
	mSynergy = STARTING_SYNERGY;
    mMovedToCeoElevator = NO;
    mSynergyDeathSequencePlaying = NO;
    mAtTopFloor = NO;
    mAtBottomFloor = YES;
}

-(void)setGameControlLayer:(GameControlLayer*)layer
{
	mControlLayer = layer;
}

@synthesize lives = mLives;

@synthesize deathSequencePlaying = mSynergyDeathSequencePlaying;

@synthesize levelUpPlaying;

-(void) setLives:(UInt8)value
{
	if( (value == mLives) || (value > NUM_LIFE_INDICATORS) )
		return;
	else
	{
		if(value < mLives)
		{
            mDeathSequencePlaying = YES;
			
			mCar.visible = NO;
            
            CGRect winRect = [[GameController sharedInstance] gamingAreaRectForPlay:YES];
            CGSize winSize = winRect.size;
            
			CGPoint wMoveTo = [self convertToNodeSpace:ccp(0, -(winSize.height + 20))];

			CCAction* wMove = [CCMoveTo actionWithDuration:3.0f position:ccp(0,wMoveTo.y)];

			
			CCSequence* wCarSeq = [CCSequence actions:
								   [CCShow action],
								   [CCEaseElasticIn actionWithAction:[[wMove copy] autorelease] period:2.0f],
								   nil];
			
			CCSequence* wBallonSeq = [CCSequence actions:
									  [CCDelayTime actionWithDuration:0.3f],
									  [CCEaseElasticIn actionWithAction:[[wMove copy] autorelease] period:2.3f],
									  [CCDelayTime actionWithDuration:AC_EL_CRASH_FALL_SPAN],
									  [CCCallFunc actionWithTarget:self selector:@selector(deathSequenceDone)],
									  nil];
			
			[mDeathElevator runAction:wCarSeq];
			[mBalloon runAction:wBallonSeq];
            [[AudioController sharedInstance] stopSound:kElevatorMoving];
            [[AudioController sharedInstance] playSound:kElevatorCrash];
            
            // ... and if the last life (zero remain) stop the music
            if(value == 0)
                [[AudioController sharedInstance] musicOff];
		}

		mLives = value;
	}
		
}

@synthesize synergy = mSynergy;

@synthesize controlLayer = mControlLayer;

@synthesize playLayer;

-(void) removePassengers:(UInt8)passengers ceo:(BOOL)fromCeo
{
    if(fromCeo)
    {
        mMovedToCeoElevator = YES;
        mBalloon.visible = NO;
        mLabelPassengers.visible = NO;
        
        CCAnimate* wPoof = [CCSequence actions:
                            [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"Poof"]],
                            [CCHide action],
                            nil];
        [mPoofAnimation runAction:wPoof];
    }
    else
    {
        [self removePassengers:passengers];
    }
}

-(void) deathSequenceDone
{
    // Reset to the current level or if no live remain then GAME OVER
    if(mLives > 0)
    {
        mMove = CGPointZero;
        
        mMovementDir = kStopped;
        
        // Cancel the flag
        mDeathSequencePlaying = NO;
        
        // Hide the death elevator sprite and reset its position
        mDeathElevator.visible = NO;
        mDeathElevator.position = CGPointZero;
        
        // Reset values for the current level and reset the position 
        // of the mCar and mBallon
        mCar.visible = YES;
        mBalloon.position = ccp(0.0f, mCar.contentSize.height);
        
        mPrevPosition = self.position;
        
        mFloor = [GameLevelMaker sharedInstance].startFloor;
        mPrevFloor = mFloor;
	

    	[mControlLayer setLevel:[GameLevelMaker sharedInstance].level];
    }
    else 
    {
        float wPension = self.controlLayer.status.pension;
        [[CCDirector sharedDirector] 
		 replaceScene:[CCTransitionMoveInB
                       transitionWithDuration:TRANSITION_DURATION 
                       scene:[GameOverLayer 
                              gameOver:wPension
                              withLevel:[GameLevelMaker sharedInstance].level]]];
    }
}

-(void) setToBottomFloor
{
    self.position = ccp(PLAY_AREA_MARGIN + ELEVATOR_SHAFT_WIDTH / 2.0f, self.halfCarHeight); 
}

-(BOOL) isUpControlAllowable
{
    if( mDeathSequencePlaying || 
       mSynergyDeathSequencePlaying || 
       mAtTopFloor || 
       (mPassengersOnboard == 0))
        return NO;
    
    return YES;
}

-(BOOL) isDownControlAllowable
{
    if( mDeathSequencePlaying || 
       mSynergyDeathSequencePlaying || 
       mAtBottomFloor || 
       (mPassengersOnboard == 0))
        return NO;
    
    return YES;
}

@end