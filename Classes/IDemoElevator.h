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
 * Basic interface for demonstration elevators. A demonstration 
 * elevator is only commanded to start or stop whatever it's
 * supposed to demo.
 */
@protocol IDemoElevator <NSObject>

@required

/** 
 * Sets the start and stop location of the elevator demonstration.
 * @param a Start location
 * @param b Stop location
 */
- (void) setStart:(CGPoint)a stop:(CGPoint) b;

/**
 * Sets the duration of the demo from point a to b.
 * @param seconds Time in seconds
 */
- (void) setDuration:(ccTime)seconds;

/**
 * Performs setup routines necessary before demo is started.
 */
- (void) prepareDemo;

/**
 * Begins the demonstration.
 */
- (void) beginDemo;

/**
 * Ends the demonstration.
 */
- (void) endDemo;

@end
