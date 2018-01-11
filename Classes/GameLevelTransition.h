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
#import "AudioController.h"

/**
 * Transition layer used to display the level number and floors.
 */
@interface GameLevelTransition : CCNode <CCTargetedTouchDelegate>
{
	CCLabelBMFont* mLevelLabel;
	CCLabelBMFont* mFloorsLabel;
	NSNumberFormatter *mFormatter;
    UInt8 mLevel;
}

/**
 * Creates a layer with text for a particular level.
 * @param level Game level
 * @param min Minimum floor number
 * @param max Maximum floor number
 * @returns Layer object
 */
+(id) transitionWithLevel:(UInt8)level floorMin:(UInt16)min floorMax:(UInt16)max;

/**
 * Initializes the layer with text for a particular level.
 * @param level Game level
 * @param min Minimum floor number
 * @param max Maximum floor number
 * @returns Layer object
 */
-(id) initWithLevel:(UInt8)level floorMin:(UInt16)min floorMax:(UInt16)max;

/**
 * Shows the transition layer for a predetermined amount of time then scrolls upward.
 */
-(void) showTransition;

/**
 * Function is called when the layer is out of view and should be removed from 
 * the parent object.
 */
-(void) transitionCleanup;

@end
