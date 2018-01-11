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

#import "MinMaxFloorStruct.h"

@class TransferElevator;
@class Elevator;
@class CeoElevator;
@class OwnGameElevator;

/**
 * Coordinates movement of all TransferElevators in the game level.
 * Parameters that define the number of elevators, their maximum speed,
 * etc, are obtained from the GameLevelMaker.
 */
@interface ShaftControl : NSObject 
{
	@private
	UInt16 mStartFloor;
	UInt16 mStopFloor;
	UInt8 mTotalElevators;
	UInt8 mActiveElevators;
	
	// Elevators that are at their closest floor, ready to move 
	// out of the way in unison
	UInt8 mElsReadyForCEO;
    UInt16 mCeoPreviewFloor;
    BOOL mGotCeoPreviewFloor;
	
	// Array of all elevators in this shaft (not all active)
	CCArray *mElevators;
	
	// Instance of CEO elevator (not used in all shafts)
	CeoElevator *mCeoElevator;
	
	CGPoint mShaftLocation;
	
	// Running
	BOOL mStarted;
	
	BOOL mIsReadyForCEO;
	BOOL mGetReadyForCEO;
	BOOL mProcessingCEO;
}

@property (nonatomic, readonly) CCArray* elevatorArray;

/**
 * Gets or sets the number of bonuses for this shaft.
 */
@property (nonatomic, readwrite) UInt8 bonusCount;

/**
 * Number of elevators used in the shaft.
 */
@property (nonatomic, readonly) UInt8 activeElevators;

/**
 * Gets whether the shaft is preparing to make room for the CEO.
 */
@property (nonatomic, readonly) BOOL gettingReadyForCEO;

/**
 * Sets the Own Elevator to control.
 * @param own Own Elevator pointer
 */
-(void) setOwnElevator:(OwnGameElevator*)own ceoElevator:(CeoElevator*)ceo;

/**
 * Sets the elevator shaft x-location.
 */
-(void) setShaftLocation:(CGPoint)location;

/**
 * Adds all the elevators in this shaft to the node.
 */
-(void) addElevatorsToNode:(CCNode*)node ceoElevator:(CeoElevator*)ceo;

/**
 * Sets a specific number of elevators to be active. 
 * @param count Number to activate
 */
-(void) setActiveElevators:(UInt8)count;

/**
 * Clears the level by ordering all elevators to move
 * to the next level. When the shaft is clear, the isReadyForCEO
 * property goes to true.
 */
-(void) clearForCEO;

/**
 * When property is true, the floor is clear of all other elevators
 * and the CEO can arrive.
 */
@property (nonatomic, readonly) BOOL isReadyForCEO;

/**
 * Uses the GameLevelMaker to retrieve new elevator shaft variables.
 */
-(void) initializeShaft;

/**
 * Stops the elevators and resets their positions to a start state.
 */
-(void) reset;

/**
 * Generates a random floor.
 */
+(UInt16) randomMinFloor:(UInt16) min maxFloor:(UInt16) max;

/**
 * Gets an array of structures which is populated with min, max, and starting floor data.
 * @param data Array of structures to fill
 * @param count Number of elevators (should match size of data)
 * @param min Minimum floor
 * @param max Maximum floor
 */
+(void) floorDataMinMax:(struct MinMaxFloor*)data elevators:(UInt8)count floorMin:(UInt16)min floorMax:(UInt16)max;

@end
