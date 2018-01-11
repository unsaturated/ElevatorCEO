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
#import "GameController.h"
#import "AudioController.h"
#import "GameLayer.h"
#import "GamePlayLayer.h"
#import "OwnGameElevator.h"

@interface GamePauseLayer : CCLayer <IMenuHandler>
{
@private	
	CCMenuItem *mConfirm;
	CCMenuItem *mRetire;
	CCMenuItem *mContinue;
    CCMenuItem *mTutorial;
    CCMenu *mMainMenu;
}

/**
 * Function is called when the layer is out of view and should be removed from 
 * the parent object.
 */
-(void) pauseCleanup;

@end
