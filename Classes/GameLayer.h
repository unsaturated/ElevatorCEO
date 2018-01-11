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

#import "GameControlLayer.h"
#import "GamePlayLayer.h"
#import "GameLevelMaker.h"
#import "CCAnimation+SequenceLoader.h"

@class GameControlLayer, GamePlayLayer;

/**
 * Root node for all game play. This contains all the 
 * objects necessary for the game itself.
 */
@interface GameLayer : CCScene
{
	@protected
	GameControlLayer *mControlLayer;
	GamePlayLayer *mPlayLayer;
}

/** 
 * Sets the running status of the game.
 * @param pause YES to pause the game
 */
-(void) pause:(BOOL)pause;

/**
 * Gets the control layer of the game.
 */
@property (nonatomic, readonly) GameControlLayer* controlLayer;

/**
 * Gets the play layer of the game.
 */
@property (nonatomic, readonly) GamePlayLayer* playLayer;

@end
