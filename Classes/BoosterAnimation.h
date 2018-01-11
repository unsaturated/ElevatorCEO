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

/**
 * Provides an animation using the booster sprite that "animates"
 * by changing the x- and y-scaling factors up and down.
 */
@interface BoosterAnimation : CCSprite
{
    float mScalingFactor;
    BOOL mActivated;
}

/**
 * Initializes a booster with a scaling factor.
 * @param scale Scaling factor
 * @returns New instance
 */
+(id) initWithScalingFactor:(float)scale;

/**
 * Internal initialize method for scaling.
 * @param scale Scaling factor
 * @returns New instance
 */
-(id) initWithScaling:(float)scale;

/**
 * Sets the scaling factor for the booster so 
 * larger or smaller elevators can utilize it.
 * @param percent Value from 0.1f to 1.0f
 */
-(void) setScalingFactor:(float)scale;

/**
 * Whether to burn the booster.
 * @param activate Set to YES to activate
 */
-(void) burn:(BOOL)activate;

@end