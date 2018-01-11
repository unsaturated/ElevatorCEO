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
#import "GameControlLayer.h"
#import "Elevator.h"
#import "GameOverLayer.h"

@class GameControlLayer, GamePlayLayer;

/**
 * The player-driven elevator that has unique 
 * properties and behaviors.
 */
@interface OwnGameElevator : Elevator 
{
	@protected
	GamePlayFloorLayer* mFloorLayer;
	GameControlLayer* mControlLayer;
	
	CCSprite* mDeathElevator;
	BOOL mDeathSequencePlaying;
    
    BOOL mMovedToCeoElevator;
	
	UInt8 mSpeed;
	BOOL mGoingDown;
	
	UInt16 mPrevFloor;
	
	CGPoint mPrevPosition;
	
	BOOL mAtTopFloor;
	BOOL mAtBottomFloor;
	
	BOOL mShouldComeToRest;
	BOOL mComingToRest;
	
	float mUpScrollPoint;
	float mDnScrollPoint;
	
	// Distance for the elevator to travel after which 
	// the speed is reset to zero (and a convenience bool)
	float mTapDistance;
	BOOL mTapped;
	UInt16 mDesiredFloor;
	
	// Stores synergy available to player
	float mSynergy;
	
	// Stores lives available to player
	UInt8 mLives;
    
    // Synergy dropped to zero and death sequence should commence
    BOOL mSynergyDeathSequencePlaying;
    
    // This is defined in the GameController but set based upon iPhone 4/5 screen size
    UInt8 mFloorsPerScreen;
}

/**
 * Sets the floor layer to control according to the 
 * own elevator's position.
 * @param floor Floor layer
 */
-(void) setFloorLayer:(GamePlayFloorLayer*)floor;

/**
 * Sets the game control layer so its actions can be assigned.
 * @param layer Main control layer
 */
-(void)setGameControlLayer:(GameControlLayer*)layer;

/**
 * Called by the bounce action at the action's completion.
 */
-(void) stopBounce;

/**
 * Gets or sets the synergy available to the player. 
 */
@property (nonatomic, readwrite) float synergy;

/**
 * Gets the number of lives the own elevator has left.
 */
@property (nonatomic, readonly) UInt8 lives;

/**
 * Gets whether the death sequence is playing.
 */
@property (nonatomic, readonly) BOOL deathSequencePlaying;

/**
 * Gets or sets whether the level-up sequence is playing.
 */
@property (nonatomic, readwrite) BOOL levelUpPlaying;

/**
 * Sets the number of lives.
 * @param value Lives to set
 */
-(void) setLives:(UInt8)value;

/**
 * Gets the game control layer.
 */
@property (nonatomic, readonly) GameControlLayer* controlLayer;

/**
 * Gets the game play layer.
 */
@property (nonatomic, retain) GamePlayLayer* playLayer;

/**
 * Removes passengers from the elevator, specifically by the CEO.
 * @param passengers Number of passengers to remove
 * @param fromCeo Whether the removal request is from the CEO
 */
-(void) removePassengers:(UInt8)passengers ceo:(BOOL)fromCeo;

/**
 * Function is called when the death sequence has completed
 * and control should be restored to the player.
 */
-(void) deathSequenceDone;

/**
 * Sets the elevator to the bottom floor location, whatever
 * the floor number.
 */
-(void) setToBottomFloor;

/**
 * Gets whether UP elevator control is permissable by 
 * Own elevator
 * @return Whether elevator can be moved
 */
-(BOOL) isUpControlAllowable;

/**
 * Gets whether DOWN elevator control is permissable by 
 * Own elevator
 * @return Whether elevator can be moved
 */
-(BOOL) isDownControlAllowable;

@end
