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

#import "ElevatorMoveEnum.h"

/**
 * Base capabilities required to define an elevator.
 */
@protocol IElevator <NSObject>

@required

/**
 * Gets or sets whether the current elevator is owned by the game player.
 */
@property (nonatomic, readwrite) BOOL isOwnElevator;

/**
 * Gets or sets whether the current elevator is the CEO.
 */
@property (nonatomic, readwrite) BOOL isCeoElevator;

/**
 * Gets the number of passengers on the elevator.
 */
@property (nonatomic, readonly) UInt8 passengersOnboard;

/**
 * Gets the passenger capacity of the elevator.
 */
@property (nonatomic, readonly) UInt8 passengerCapacity;


/**
 * Set the initial count of passengers or available slots.
 * @param count Total to set
 */
-(void) initializePassengers:(UInt8)count;

/**
 * Called when the a new level is started.
 */
-(void) initializeLevel;

/**
 * Removes passengers from the elevator.
 * @param passengers Number of passengers to remove
 */
-(void) removePassengers:(UInt8)passengers;

/**
 * Adds passengers to the elevator.
 * @param passengers Number of passengers to add
 */
-(void) addPassengers:(UInt8)passengers;

/**
 * Gets the floor where the elevator is located.
 */
@property (nonatomic, readonly) UInt16 floor;

/**
 * Gets the minimum floor the elevator can go.
 */
@property (nonatomic, readonly) UInt16 floorMin;

/**
 * Gets the maximum floor the elevator can go.
 */
@property (nonatomic, readonly) UInt16 floorMax;

/**
 * Gets the floor the elevator is going to.
 */
@property (nonatomic, readonly) UInt16 floorGoingTo;

/**
 * Gets the movement direction/status.
 */
@property (nonatomic, readonly) Movement movementDir;

/**
 * Sets whether the booster is burning.
 @param activate True sets the booster to burn
 */
-(void) burnBooster:(BOOL)activate;

/**
 * Gets whether the elevator booster is burning.
 */
@property (nonatomic, readonly) BOOL isBoosterBurning;

@optional

/**
 * Moves the elevator to the specified floor.
 * @param floor Desired floor
 */
-(void) moveTo:(UInt16)floor;

/**
 * Instantly moves the elvator to the specified floor.
 * @param floor Desired floor
 */
-(void) setTo:(UInt16)floor;

/**
 * Sets the floor minimum and maximum.
 * @param minValue Minimum
 * @param maxValue Maximum
 */
-(void) setFloorMin:(UInt16)minValue max:(UInt16)maxValue;

/** 
 * Moves the container at a speed relative to the own elevator.
 */
-(void) moveSpeed:(UInt8)speed withTap:(BOOL)tap directionDown:(BOOL)down;

/**
 * Call to remove any selectors used in the object.
 */
-(void) unscheduleSelectors;

@end
