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

#import "Elevator.h"
#import "OwnGameElevator.h"
#import "ElevatorTimer.h"
#import "BonusEnumerations.h"
#import "GameLevelMaker.h"
#import "CCAnimation+SequenceLoader.h"
#import "AudioController.h"

/**
 * The elevator that is driven by the game logic
 * and only used to transfer passengers from the 
 * OwnGameElevator.
 */
@interface BaseTransferElevator : Elevator 
{	
@protected
	UInt8 mSpeed;
	BOOL mGoingDown;
	
	UInt16 mPrevFloor;
	
	CGPoint mPrevPosition;
	
	BOOL mAtTopFloor;
	BOOL mAtBottomFloor;
	
	BOOL mShouldComeToRest;
	BOOL mComingToRest;
	BOOL mActiveInGame;
	BOOL mDisplayingBonus;
	
	// Whether the elevator has reached the requested floor
	BOOL mReachedFloor;
	BOOL mInTransit;
	
	float mTopFloorBottomY;
	float mBtmFloorBottomY;
	
	float mFloorGoingToY;
	
	Bonus mBonus;
	
	float mTimeAtFloor;
	
	UInt16 mFloorRangeMin;
	UInt16 mFloorRangeMax;
	
	OwnGameElevator* mOwnElevator;
	
	CCSprite* mChestAnimation;
	
	CCSprite* mBonusSprite;
	
	ElevatorTimer* mTimerIndicator;
}

/**
 * Required to redefine this so sub-classes know
 * how to call [super update:dt]
 */
-(void) update:(ccTime)dt;

/**
 * Sets the Own Elevator if it is not itself the Own Elevator
 * @param elevator Reference to the Own Elevator
 */
-(void) setOwnElevator:(OwnGameElevator*)elevator;

/**
 * Gets whether the elevator is currently active in the game.
 * The elevator instance may be available but not all transfer 
 * elevators are used in every game level.
 */
@property (nonatomic, readwrite) BOOL activeInGame;

/** 
 * Gets whether the elevator reached the desired floor.
 */
@property (nonatomic, readonly) BOOL reachedFloor;

/**
 * Gets whether the elevator is in transit to a floor.
 */
@property (nonatomic, readonly) BOOL inTransit;

/**
 * Called by the bounce action at the action's completion.
 */
-(void) stopBounce;

/**
 * Sets the bonus the elevator is holding.
 * @param b Bonus to use
 */
-(void) setBonus:(Bonus)b;

/**
 * Sets the floor range, which is controlled separately from
 * the floor min/max because it does not control the x- and y-
 * range.
 * @param min Floor minimum
 * @param max Floor maximum
 */
-(void) setFloorRangeMin:(UInt16)min maximum:(UInt16)max;

/**
 * Gets the minimum floor this elevator can go to.
 */
@property (nonatomic, readonly) UInt16 floorRangeMin;

/**
 * Gets the maximum floor this elevator can go to.
 */
@property (nonatomic, readonly) UInt16 floorRangeMax;

/**
 * Moves the elevator to the specified floor, overriding
 * the min or max floor.
 * @param floor Floor to go to
 * @param over Whether to override
 */
-(void) moveTo:(UInt16)floor overrideMinMax:(BOOL)ovr;

/**
 * Gets the time spent at the current floor. Resets to zero during transit.
 */
@property (nonatomic, readonly) float timeAtFloor;

/**
 * Called when the bonus animation has completed.
 */
-(void) bonusAnimationComplete;

@end
