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

#define SCORE_DATE_KEY      @"GameScoreDate"
#define SCORE_LEVEL_KEY     @"GameScoreLevel"
#define SCORE_PENSION_KEY   @"GameScorePension"

#define SCORE_FILE_NAME     @"CeoScoreData.dat"

#import "GameController.h"

@interface GameScore : NSObject <NSCoding>
{
    NSDate* mDate;
    UInt16 mLevel;
    float mPension;
    NSNumberFormatter *mNumFormatter;
    NSDateFormatter *mDateFormatter;
}

/**
 * Class method to create a new GameScore object.
 * @param date Date of game
 * @param l Level of game
 * @param p Pension of game
 * @return New score object
 */
+(id) fromDate:(NSDate*)date level:(UInt16)l pension:(float)p;

/**
 * Saves all game scores from the provided array.
 * @param scores Array of GameScore objects (some or all can be nil)
 */
+(void) saveGameScoresLocally:(CCArray*)scores;

/**
 * Retuns an array of game scores loaded from local file system.
 * @return Array of GameScore objects (some or all can be nil)
 */
+(CCArray*) loadGameScoresLocally;

/**
 * Initializes the object with a date, level, and pension.
 * @param date Date and time
 * @param l Score level
 * @param p Score pension
 */
-(id) initWithDate:(NSDate*)date level:(UInt16)l pension:(float)p;

/**
 * Sets up the localization formatters.
 */
-(void) setupFormatters;

/**
 * Gets or sets the date and time.
 */
@property (nonatomic, retain) NSDate* dateTime;

/**
 * Gets or sets the score's level.
 */
@property (nonatomic, readwrite) UInt16 level;

/**
 * Gets or sets the score's pension.
 */
@property (nonatomic, readwrite) float pension;

/**
 * Gets the formatted date (kCFDateFormatterShortStyle) and time using the localization.
 */
-(NSString*) localizedDateAndTime;

/**
 * Gets the formatted level using the localization.
 */
-(NSString*) localizedLevel;

/**
 * Gets the pension using the localization.
 */
-(NSString*) localizedPension;

@end

