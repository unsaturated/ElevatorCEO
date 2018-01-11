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
 * Displays a quanity of time remaining for the elevator at its current level
 * using bars. Status is set using percetage (from 0.0 - 100.0 inclusive), 
 * since time quantity can vary by level.
 */
@interface ElevatorTimer : CCNode 
{
@protected
	float mPercentRemain;
	CCArray *mBars;
}


/**
 * Sets the time remaining as a percentage.
 * @param percent Percentage to set from 0 - 100, inclusive
 */
-(void) setPercent:(float)percent;

@end
