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

/**
 * The CEO's elevator is a type of transfer elevator. The main
 * difference is the color of the elevator.
 */
@interface CeoElevator : BaseTransferElevator 
{
	@protected
	UInt8 mStopsRemaining;
    BOOL mInformedLevelFailed;
}

/**
 * Gets or sets the total number of stops the CEO is going 
 * to make for the current level
 */
@property (nonatomic, readwrite) UInt8 totalStops;

/**
 * Gets or sets the stop remaining for the current level.
 */
@property (nonatomic, readwrite) UInt8 stopsRemaining;

/**
 * Gets or sets the time to remain at each stop on the current level.
 */
@property (nonatomic, readwrite) float timeAtEachStop;

/**
 * Called to increment the level when the CEO has started 
 * to move upward.
 */
-(void) levelUpWithCeo;

/**
 * Gets a preview of the floor the CEO is going to 
 * before the moveTo function is called.
 */
@property (nonatomic, readwrite) UInt16 floorGoingToPreview;

@end
