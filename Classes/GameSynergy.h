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
 * Displays a quanity of time (or synergy) remaining
 * from 0.0 - 100.0 inclusive. Animation at various levels 
 * is built into the object properies.
 */
@interface GameSynergy : CCLayer 
{
	@protected
	float mSynergyLevel;
	CCArray *mRedBars;
	CCArray *mYellowBars;
	CCArray *mGreenBars;
	CCArray *mGrayBars;
	CCArray *mAllColorBars;
	UInt8 mBarsVisible;
}

/**
 * Gets the current synergy level.
 */
@property (nonatomic, readonly) float synergyLevel;

/**
 * Sets the synergy level.
 * @param level Synergy to set from 0 - 100, inclusive
 */
-(void) setSynergy:(float)level;

@end
