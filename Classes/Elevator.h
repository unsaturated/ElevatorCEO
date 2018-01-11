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

#import "GameController.h"
#import "IElevator.h"
#import "ElevatorMoveEnum.h"
#import "BoosterAnimation.h"
#import "ShaftControl.h"

/**
 * Layer object that creates the appearance and has the the features
 * of an elevator. All elevator objects should derive from this type.
 */
@interface Elevator : CCNode <IElevator,CCTargetedTouchDelegate>
{
	@protected
	
	// Objects on the elevator
	CCSprite *mCar;
	CCSprite* mBalloon;
	CCLabelBMFont *mLabelPassengers;
    CCSprite* mPoofAnimation;
	
    // Reward (HUD)
    CCLabelBMFont *mPensionReward;
    
	// Properties of the elevator
	BOOL mIsOwnElevator;
	UInt8 mPassengersOnboard;
	UInt8 mPassengerCapacity;
	
	// Position of elevator
	UInt16 mFloor;
    
    // Lock for touched elevators
    BOOL mTouched;
	
	// Effects
    BoosterAnimation* mBooster;
	BOOL mBoosterBurning;
    float mBoosterScalingFactor;
	
	// Min/max for floor
	UInt16 mFloorMin;
	UInt16 mFloorMax;
	
	// Going to floor
	UInt16 mFloorGoingTo;
	
	// Vector of movement
	CGPoint mMove;
	
	Movement mMovementDir;
    
    NSNumberFormatter *mFormatter;
}

/**
 * Gets the direction of movement.
 */
@property (nonatomic, readonly) CGPoint movement;

/**
 * Called when the elevator receives a touch event.
 */
-(void) touched;

/**
 * Gets half the car height for convenience.
 */
@property (nonatomic, readonly) float halfCarHeight;

/**
 * Animates all pension increases when transferring passengers.
 */
-(void) animatePension:(float)amount;

/**
 * Gets or sets the shaft in which the elevator resides.
 */
@property (nonatomic, retain) ShaftControl* shaft;

@end
