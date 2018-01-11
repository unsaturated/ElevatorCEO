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

#import "CeoElevator.h"

@implementation CeoElevator

-(id) init
{
	if( (self=[super init] )) 
	{
		// register to receive targeted touch events
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
														 priority:0
												  swallowsTouches:NO];
		
		// The blue elevator is the smallest
		mCar = [CCSprite spriteWithSpriteFrameName:@"el-red-game.png"];
		mCar.position = ccp(0, 0);
		[self addChild: mCar z:2];
		
		// Add some fire
		mBooster = [BoosterAnimation initWithScalingFactor:0.6f];
		mBooster.position = ccp(0, -30);
		[self addChild: mBooster z:1];
		[self burnBooster:NO];
		
		[self scheduleUpdate];
		
		// This is the main game play elevator
		mIsOwnElevator = NO;
		
		// This is the CEO's elevator
		self.isCeoElevator = YES;
		
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
        
        mInformedLevelFailed = NO;
		
		mTopFloorBottomY = mBtmFloorBottomY = mFloorGoingToY = 0;
		
		self.position = ccp(0, self.halfCarHeight);
		mPrevPosition = self.position;
		
		mBalloon = [CCSprite spriteWithSpriteFrameName:@"dialog.png"];
		mBalloon.position = ccp(self.position.x, self.position.y * 2.0f);
		[self addChild:mBalloon z:3];
		
		mLabelPassengers = [CCLabelBMFont labelWithString:@"0" fntFile:[GameController selectFont:kDroidSansBold20Black forceDefault:YES]];
		mLabelPassengers.position = ccp(self.position.x, self.position.y * 2.0f);
		mLabelPassengers.visible = YES;
		[self addChild:mLabelPassengers z:4];
				
		mTimerIndicator = [ElevatorTimer node];
		mTimerIndicator.position = ccp((mCar.contentSize.width / 2.0f - mTimerIndicator.contentSize.width / 2.0f), 6.0f);
		[mCar addChild:mTimerIndicator z:5];
        
        floorGoingToPreview = UINT16_MAX;
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

-(void) dealloc
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    CCLOG(@"---DEALLOC %@", self);
    [super dealloc];
}

@synthesize totalStops = mTotalStops;

/**
 * Gets or sets the stop remaining for the current level.
 */
@synthesize stopsRemaining = mStopsRemaining;

/**
 * Gets or sets the time to remain at each stop on the current level.
 */
@synthesize timeAtEachStop = mTimeAtEachStop;

-(void) initializeLevel
{
    [super initializeLevel];
    mTouched = NO;
    mInformedLevelFailed = NO;
    [self burnBooster:NO];
}

-(void) update: (ccTime)dt
{
    [super update:dt];
    // Wait for the CEO to pass between the Own elevator max floor 
    // and the max floor + 20 - a range is more reliable than exact numbers
    // and the CEO current floor evaluates (initially) to a large number
    // that can't be relied upon.
    // The other conditions are mostly self-explanatory.
    //if( (mFloor > mOwnElevator.floorMax) && 
    //   (mFloor < mOwnElevator.floorMax + 20) 
    //&& !mInformedLevelFailed )
    
    if(mFloor >= mFloorMax && !mInformedLevelFailed && (mFloorGoingTo != 0) && !mOwnElevator.deathSequencePlaying)
       {
           CCLOG(@"Used to be an error condition!");
           CCLOG(@"But because mOwnElevator.levelUpPlaying is %d, it will/won't happen again!", mOwnElevator.levelUpPlaying);
       }
    
    if(mFloor >= mFloorMax && !mInformedLevelFailed && (mFloorGoingTo != 0) && !mOwnElevator.deathSequencePlaying && !mOwnElevator.levelUpPlaying)
    {
        // The CEO just passed through the level, so remove a player life
        // which in this case would also mean the last passenger
        [mOwnElevator removePassengers:1];
        mInformedLevelFailed = YES;
    }
}

-(void) touched
{	
	// If this elevator is on the same floor as the Own Elevator, then...
    
    // Escape early if already touched
    if(mTouched)
        return;
    
    // Don't even bother if you can't see it
    if(!self.visible)
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
                mOwnElevator.levelUpPlaying = YES;
				[mOwnElevator removePassengers:self.passengersOnboard ceo:YES];
				
				[mOwnElevator.controlLayer.status changePensionBy:(self.passengersOnboard * TRANSFER_VALUE)];
				
                // Add the own player, burn the booster, hide
                // the timer indicator, and overclock the time
                // at floor to make the CEO start moving immediately
				[self addPassengers:1];	
				[self burnBooster:YES];
                [mTimerIndicator setPercent:0.0f];
                mTimeAtFloor = 100.0f;
                mSpeed = 10;
                
                // Play whoosh and stinger
                [[AudioController sharedInstance] playSound:kBooster];
                [[AudioController sharedInstance] playSound:kStinger];
                
                CCParticleFireworks* fireworks = [CCParticleSmoke node];
                if([self getChildByTag:1212] == nil)
                {
                    [self addChild:fireworks z:0 tag:1212];
                }
                else 
                {
                    [self removeChildByTag:1212 cleanup:YES];
                    [self addChild:fireworks z:0 tag:1212];
                }
                fireworks.texture = [[CCTextureCache sharedTextureCache] textureForKey:@"fire.png"];
                fireworks.duration = 0.6f;
                fireworks.scale = 0.6f;
                fireworks.position = mBooster.position;
                
                [self.parent runAction:[CCSequence actions:
                                 [CCDelayTime actionWithDuration:TRANSITION_DELAY_AFTER_CEO],
                                 [CCCallFunc actionWithTarget:self selector:@selector(levelUpWithCeo)],
                                 nil]];
			}
		}
	}
}

-(void) levelUpWithCeo
{	
    // No more stops remaining
    self.stopsRemaining = 0;
    
	// Reset to the current level
    GameControlLayer* wControl = mOwnElevator.controlLayer;
    UInt8 wNextLevel = [GameLevelMaker sharedInstance].level + 1;
    [[GameLevelMaker sharedInstance] calculateLevel:wNextLevel];
	[wControl setLevel:wNextLevel];
}

@synthesize floorGoingToPreview;

-(void) moveTo:(UInt16)floor
{
    [super moveTo:floor];
}

@end
