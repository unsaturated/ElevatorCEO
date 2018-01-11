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

#import "GamePlayFloorLayer.h"
#import "GameLevelTransition.h"
#import "GamePauseLayer.h"
#import "BaseTutorialTip.h"

@class GamePlayFloorLayer, GameControlLayer, Elevator, OwnGameElevator, TransferElevator, CeoElevator, ShaftControl;

/**
 * Playing area within the containing GameLayer object. This 
 * includes the floors, game messages, elevators, and pretty much 
 * everything that's not a part of the GameControlLayer.
 */
@interface GamePlayLayer : CCLayer
{
	@protected
	GamePlayFloorLayer *mFloorLayer;
	OwnGameElevator *mOwnElevator;
	CeoElevator *mCeoElevator;
    GameControlLayer* mControlLayer;
	
	// Transfer elevator shafts are numbered 1 (far left) to 4 (right)
	ShaftControl *mShaft1;
	ShaftControl *mShaft2;
	ShaftControl *mShaft3;
	ShaftControl *mShaft4;
    
    // Points and clipping
	CGRect mVisibleRect;
}

/**
 * Finailizes the gaming area for a new level, including the presentation of 
 * the transition layer.
 */
-(void) initializeWithLevel;

/** 
 * Shows the pause layer and returns the instance used in-game.
 */
-(void) showPauseMenu;

/**
 * Clears the pause menu layer
 */
-(void) clearPauseMenu;

/**
 * Sets the game control layer so its actions can be assigned.
 * @param layer Main control layer
 */
-(void) setGameControlLayer:(GameControlLayer*) layer;

/** 
 * Moves the floor at the specified speed and direction.
 * @param oneFloor Whether to move one floor
 * @param speed Speed to move floors
 * @param down To move floors down
 */
-(void) moveFloorSpeed:(BOOL)oneFloor withSpeed:(UInt8) speed directionDown:(BOOL)down;

/**
 * Sets the floor min and max.
 * @param max maximum floor
 */
-(void) setFloorMinimum:(UInt16)min maximum:(UInt16)max; 

/**
 * Shows a tutorial tip.
 * @param tip Tip to display
 */
-(void) showTip:(BaseTutorialTip*)tip;

/**
 * Used for first level and activated by delay action.
 */
-(void) startupTips;

/**
 * The player has managed to level up so make sure all the
 * tips are removed from view.
 * @param tutorialViewed Set to YES to consider the tutorial viewed
 */
-(void) removeAllTips:(BOOL)tutorialViewed;

/**
 * Get the own elevator.
 */
@property (nonatomic, readonly) OwnGameElevator* ownElevator;

/**
 * Get the CEO elevator.
 */
@property (nonatomic, readonly) CeoElevator* ceoElevator;

@property (nonatomic, readonly) GamePlayFloorLayer* floorLayer;

/**
 * Get the transfer elevator shaft #1.
 */
@property (nonatomic, readonly) ShaftControl* transferShaft1;

/**
 * Get the transfer elevator shaft #2.
 */
@property (nonatomic, readonly) ShaftControl* transferShaft2;

/**
 * Get the transfer elevator shaft #3.
 */
@property (nonatomic, readonly) ShaftControl* transferShaft3;

/**
 * Get the transfer elevator shaft #4.
 */
@property (nonatomic, readonly) ShaftControl* transferShaft4;

/**
 * Gets an x-location for the shaft requested.
 * @param number The shaft number (1-5)
 * @returns X-location to center elevator
 */
+(float) locationForShaft:(UInt8) number;

@end
