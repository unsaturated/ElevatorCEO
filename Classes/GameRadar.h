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

#import "GameRadarContents.h"

/**
 * Provides an overview of the in-game elevators. Their positions
 * within the current level are displayed to so the game player 
 * doesn't have to senselessly search up and down for available 
 * transfer elevators. It uses the GameRadarContents, which 
 * clips the visible area. 
 */
@interface GameRadar : CCNode 
{
	@protected
	GameRadarContents* mContents;
}

@property (nonatomic, readonly) GameRadarContents* contents;

/**
 * Sets the array object of elevators for a specific floor. This should
 * be called before the radar is used.
 */
-(void) setShaftElevatorsOn:(UInt16)floor with:(CCArray*)array;

/**
 * Sets the own elevator and CEO elevator objects. This should be called 
 * before the radar is used.
 */
-(void) setOwnElevator:(OwnGameElevator*)own ceoElevator:(CeoElevator*)ceo;

/**
 * Sets the floor minimum and maximum.
 * @param max Maximum floor
 */
-(void) setFloorMinimum:(UInt16)min maximum:(UInt16)max;

/**
 * Hides the elevator display for a total number of floors.
 * @param total Number of floors to hide the radar
 */
-(void) hideRadarForFloors:(UInt16)total;

@end
