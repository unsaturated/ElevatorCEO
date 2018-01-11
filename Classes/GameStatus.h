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
#import "GameSynergy.h"

/** 
 * Display area that provides the vital statistics of the 
 * game, such as pension (points), level attained, the number
 * of lives remaining, and synergy (fuel or time) remaining.
 */
@interface GameStatus : CCLayer 
{
	@protected
	GameSynergy *mSynergy;
	CCSprite *mBackground;
	CCArray *mLifeSprites;
	UInt16 mLevel;
	float mPension;
	UInt8 mLives;
	CCLabelBMFont *mLabel1;
	CCLabelBMFont *mLabel2;
	CCLabelBMFont *mLabel3;
	CCLabelBMFont *mLabelPension;
	CCLabelBMFont *mLabelLevel;
	NSNumberFormatter *mFormatter;
}

/**
 * Gets or sets the synergy level displayed.
 */
@property (nonatomic, readwrite) float synergyLevel;

/**
 * Gets or sets the number of lives displayed. This 
 * can be a minimum of zero or maximum of 3.
 */
@property (nonatomic, readwrite) UInt8 lives;

/**
 * Gets or sets the game level.
 */
@property (nonatomic, readwrite) UInt16 level;
	
/**
 * Gets or sets the pension dollar ($) amount.
 */
@property (nonatomic, readwrite) float pension;

/**
 * Changes the pension by the given amount (increase or decrease).
 * @param amount Pension quantity to increase or decrease
 */
-(void) changePensionBy:(float)amount;

/**
 * Changes the synergy by the given amount (increase or decrease).
 * @param amount Synergy to increase or decrease
 */
-(void) changeSynergyBy:(float)amount;

@end
