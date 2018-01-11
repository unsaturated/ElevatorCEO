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

#import "GameScore.h"

@implementation GameScore

+(id) fromDate:(NSDate *)date level:(UInt16)l pension:(float)p
{
    return [[[self alloc] initWithDate:date level:l pension:p] autorelease];
}

+(void) saveGameScoresLocally:(CCArray*)scores
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gameStatePath = [documentsDirectory stringByAppendingPathComponent:SCORE_FILE_NAME];
    
    // Set up the encoder and storage for the game state data
    NSMutableData *gameScoreData = [[NSMutableData alloc] init];
    NSKeyedArchiver *encoder =[[NSKeyedArchiver alloc] initForWritingWithMutableData:gameScoreData];
    
    // Archive our object
    GameScore* wScore;
    UInt8 i = 0;
    CCARRAY_FOREACH(scores, wScore)
    {
        if(wScore != nil)
        {
            [encoder encodeObject:wScore forKey:[NSString stringWithFormat:@"top%d", i]];
            i++;
        }
    }
    
    // Finish encoding and write to the SCORE_FILE_NAME file
    [encoder finishEncoding];
    [gameScoreData writeToFile:gameStatePath atomically:YES];
    [encoder release];
    [gameScoreData release];    
}

+(CCArray*) loadGameScoresLocally
{
    // Check to see if there is a gameState.dat file.  If there is then load the contents
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Check to see if the SCORE_FILE_NAME file exists and if so load the contents
    NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:SCORE_FILE_NAME];
    NSData *gameScoreData = [[[NSData alloc] initWithContentsOfFile:documentPath] autorelease];
	
	if(gameScoreData) 
    {
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:gameScoreData];
        
        CCArray* wScores = [CCArray array];
		// Set the local instance of myObject to the object held in the gameState file with the key "myObject"
        for(UInt8 i = 0; i < MAX_GAME_HIGH_SCORES; i++)
        {
            GameScore* wScore = [decoder decodeObjectForKey:[NSString stringWithFormat:@"top%d", i]];
            if(wScore != nil)
                [wScores addObject:wScore];
        }
		
		// Finished decoding the objects 
        [decoder finishDecoding];
		[decoder release];
        
        return wScores;
	} 
    
    // The file doesn't exist
    return nil;  
}

-(id) initWithDate:(NSDate *)date level:(UInt16)l pension:(float)p
{
    if( self = [super init])
    {
        [self setupFormatters];
        
        mDate = [date retain];
        mLevel = l;
        mPension = p;
    }
    
    return self;
}

-(void) setupFormatters
{
    // Localize the pension amount
    mNumFormatter = [[[NSNumberFormatter alloc] init] retain];
    [mNumFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [mNumFormatter setMaximumFractionDigits:0];
        
    NSString* wCalLocale = [[NSCalendar currentCalendar] calendarIdentifier];
    mDateFormatter = [[[NSDateFormatter alloc] init] retain];
    
    // Only display regional date if not a Chinese locale and it is the Gregorian calendar
    if([wCalLocale isEqualToString:NSCalendarIdentifierGregorian] && ![GameController isChineseLocale])
    {
        // Calendar is Gregorian, so go ahead with localized formatting
        [mDateFormatter setDateStyle:kCFDateFormatterShortStyle];
        [mDateFormatter setTimeStyle:kCFDateFormatterShortStyle];
    }
    else
    {
        // Explicitly format without locale if some other calendar type is used
        [mDateFormatter setDateFormat:@"yyyy-MM-dd  HH:mm"];
    }
}

-(void) dealloc
{
    [mDate release];
    [mNumFormatter release];
    [mDateFormatter release];
    [super dealloc];
}

#pragma mark Properties

@synthesize dateTime = mDate;

@synthesize level = mLevel;

@synthesize pension = mPension;

#pragma mark Properties Localized

-(NSString*) localizedDateAndTime
{
    return [mDateFormatter stringFromDate:self.dateTime];
}

-(NSString*) localizedLevel
{
    NSString *formatted = [mNumFormatter stringFromNumber:[NSNumber numberWithInt:self.level]];
    return [GameController convertToAscii:formatted];
}

-(NSString*) localizedPension
{
    NSString* formatted = [mNumFormatter stringFromNumber:[NSNumber numberWithFloat:self.pension]];
    return [GameController convertToAscii:formatted];
}

#pragma mark NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.dateTime forKey:SCORE_DATE_KEY];
    [aCoder encodeInt32:self.level forKey:SCORE_LEVEL_KEY];
    [aCoder encodeFloat:self.pension forKey:SCORE_PENSION_KEY];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSDate* d = (NSDate*)[aDecoder decodeObjectForKey:SCORE_DATE_KEY];
    UInt16 l = (UInt16)[aDecoder decodeInt32ForKey:SCORE_LEVEL_KEY];
    float p = (float)[aDecoder decodeFloatForKey:SCORE_PENSION_KEY];
    
    return [self initWithDate:d level:l pension:p];
}

@end
