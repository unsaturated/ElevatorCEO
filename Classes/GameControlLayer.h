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

#import "GameSynergy.h"
#import "GameStatus.h"
#import "GameRadar.h"
#import "GameUpDownButton.h"
#import "GamePlayLayer.h"
#import "IMenuHandler.h"
#import "GamePauseLayer.h"

@class GamePlayLayer;

/**
 * Main controls associated with game play. This is part 
 * of the GameLayer object.
 */
@interface GameControlLayer : CCLayer <IMenuHandler,ButtonUpDownDelegate>
{
	@protected
	
	// Game lives, synergy, etc
	GameStatus *mStatus;
	
	// Game radar (preview)
	GameRadar *mRadar;
	
	// Menu / buttons
	CCMenuItem *mMusicOnMenuItem;
	CCMenuItem *mMusicOffMenuItem;
	CCMenuItem *mSoundOnMenuItem;
	CCMenuItem *mSoundOffMenuItem;
	CCMenuItem *mPauseMenuItem;
    CCMenuItem *mSwapMenuItem;
	
	CCMenuItemToggle *mMusicItem;
	CCMenuItemToggle *mSoundItem;
	
	GameUpDownButton *mUpButton;
	GameUpDownButton *mDownButton;
	
	GamePlayLayer *mPlayLayer;
}

/**
 * Handles button press from the music on/off button.
 * @param sender Object the sent the press
 */
-(void)musicButtonTapped:(id)sender;

/**
 * Handles button press from the sound on/off button.
 * @param sender Object the sent the press
 */
-(void)soundButtonTapped:(id)sender;


/**
 * Used for generic cleanup of selectors and other memory.
 */
-(void)unscheduleSelectors;

/**
 * Sets the game play layer so its actions can be assigned.
 * @param layer Main game play layer
 */
-(void)setGamePlayLayer:(GamePlayLayer*)layer;

/** 
 * Swaps the control side with the game play side.
 */
-(void)swapControlSide;

/**
 * Sets the level for game play.
 * @param level Play level
 */
-(void)setLevel:(UInt8)level;

/**
 * Shows the pause menu.
 */
-(void) showPauseMenu;

/**
 * Clears the pause background and does any cleanup when resuming.
 */
-(void) clearPauseMenu;

/**
 * Gets an array of random values with no duplicates.
 @param array Array to fill
 @param min Minimum value
 @param max Maximum value
 @param count Total values to generate
 */
+(void) getRandomValues:(CCArray*)array minimum:(UInt8)min maximum:(UInt8)max totalValues:(UInt8)count;

@property (nonatomic, readonly) GameStatus* status;

@property (nonatomic, readonly) GameRadar* radar;

@end
