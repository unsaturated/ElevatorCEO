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

#import "IMenuHandler.h"

/**
 * Displays a simple GAME OVER layer with the final pension
 * and level. It also includes a single button that re-directs 
 * to the main menu.
 */
@interface GameOverLayer : CCLayer <IMenuHandler> 
{
    @private
    CCMenuItem *mBackButton;
    CCMenuItem *mGameCenterButton;
    
	CCLabelBMFont* mLevelLabel;
    CCLabelBMFont* mLevelLabelExtended;
	CCLabelBMFont* mPensionLabel;
    CCLabelBMFont* mTopThree;
	NSNumberFormatter *mFormatter;
    float mPension;
}

/**
 * Creates a layer with game over text, pension, and level.
 * @param pension Final pension
 * @param level Final level
 * @return Layer object
 */
+(id) gameOver:(float)pension withLevel:(UInt16)level;

/**
 * Initializes the layer with game over text, pension, and level.
 * @param pension Final pension
 * @param level Final level
 * @return Layer object
 */
-(id) initGameOver:(float)pension withLevel:(UInt16)level;

/**
 * Performs final cleanup of selectors and events
 */
-(void)unscheduleSelectors;

@end