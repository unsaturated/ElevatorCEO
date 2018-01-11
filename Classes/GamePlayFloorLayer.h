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

/**
 * Draws the floor sprites. A set of sprites is revolved from 
 * top to bottom, or in reverse, to indicate a matching speed
 * for the OwnGameElevator.
 */
@interface GamePlayFloorLayer : CCLayer 
{
	@protected
	
	// An array of level sprites that together form the play area background
	CCArray *mFloorSprites;
	
	// An array of sprites for displaying the floor number
	CCArray *mFontSprites;
	
	// Sprite displayed at maximum floor for the current level
	CCSprite *mLevelDivider;
	
	// Stores the floor minimum for any particular level of the game
	UInt16 mFloorMin;
	
	// Stores the floor maximum for any particular level of the game
	UInt16 mFloorMax;
	
	// Maximum possible y-position of the floor
	float mFloorMaxY;
	
	// Maintains the last position to know when to wrap the floor graphics
	CGPoint mLastWrapPosition;
	
	// Used to track which sprite index is now located at the top of the display
	UInt8 mSpriteIndexTop;
	
	// Used to track which sprite index is now located at the bottom of the display
	UInt8 mSpriteIndexBottom;
	
	// Whether the elevator can move upwards
	BOOL mCanElevatorMoveUp;
	
	// Whether the elevator can move downwards
	BOOL mCanElevatorMoveDown;
	
	// Used to calculate movement independent of what originated the movement
	CGPoint mPrevPosition;
	
	// Master control for adjusting direction and speed
	CGPoint mMove;
	
	// Externally requested speed
	UInt8 mSpeed;
    
    BOOL mResetting;
    
    // This is defined in the GameController but set based upon iPhone 4/5 screen size
    UInt8 mFloorsPerScreen;
    UInt8 mLevelSpritesPerScreen;
    UInt8 mNumLevelSprites;
}

/**
 * Gets the floor minimum for the current game level.
 */
@property (nonatomic, readonly) UInt16 floorMin; 

/**
 * Gets the floor maximum for the current game level.
 */
@property (nonatomic, readonly) UInt16 floorMax; 

/**
 * Sets the floor minimum and maximum.
 * @param minValue Minimum
 * @param maxValue Maximum
 */
-(void) setFloorMin:(UInt16)minValue max:(UInt16)maxValue;

/**
 * Gets whether the elevator can move upwards. The property is 
 * actually an indication of whether the floors can scroll in 
 * the direction that indicates the elevator is moving upwards.
 */
@property (nonatomic, readonly) BOOL canElevatorMoveUp;

/**
 * Gets whether the elevator can move downwards. The property is 
 * actually an indication of whether the floors can scroll in 
 * the direction that indicates the elevator is moving downwards.
 */
@property (nonatomic, readonly) BOOL canElevatorMoveDown;

/** 
 * Moves the floor at the given speed
 */
-(void) moveSpeed:(float)speed directionDown:(BOOL)down;

/**
 * Gets the floor number from the elevator position.
 * @param pos Position of elevator
 * @returns Floor number
 */
-(UInt16) floorFromPosition:(CGPoint)pos;

/**
 * Gets the distance to the bottom of the specified floor.
 * @param floor Floor number
 * @param pos Position of elevator
 * @returns Distance (positive or negative) to middle of floor
 */
-(float) distanceToFloorBtm:(UInt16)floor atPosition:(CGPoint)pos;

/**
 * Resets the floor to the starting locations. This should be used
 * when the Own Elevator is also reset.
 * @param minValue Minimum
 * @param maxValue Maximum
 */
-(void) reset:(UInt16)minValue max:(UInt16)maxValue;

@end
