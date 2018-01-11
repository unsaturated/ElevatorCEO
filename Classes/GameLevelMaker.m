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

#import "GameLevelMaker.h"
#import "GameController.h"
#import "BonusEnumerations.h"

static GameLevelMaker* mInstance = nil;

@implementation GameLevelMaker

#pragma mark Level Properties ________________________

@synthesize level = mLevel;

@synthesize floors = mFloors;

@synthesize startFloor = mStartFloor;

@synthesize stopFloor = mStopFloor;

@synthesize passengers = mOwnElevatorPassengers;

@synthesize stopsByCEO = mStopsByCEO;

@synthesize stopTimeByCEO = mStopTimeByCEO;

@synthesize numberOfElevators = mElevatorCount;

@synthesize bonuses;

@synthesize stopTime = mStopTime;

@synthesize elevatorSpeed = mElevatorSpeed;

#pragma mark Level Functions ________________________ 

-(void) calculateLevel:(UInt8)level
{
	// Why? Just do it in case I mess up somewhere.
	if(level < 1)
		return;
	
	// Initialize to 1, use "level" later
	UInt8 wCalcLevel = 1;
	
	// Level 1 is a special case that doesn't depend upon any previous values.
		
	// Level
	mLevel_Cr = mLevel_Pr = 1;
	
	// Floors
	mFloors_Cr = mFloors_Pr = INITIAL_FLOORS;
	
	// Start Floor
	mStartFloor_Cr = mStartFloor_Pr = START_FLOOR;
	
	// Stop Floor
	mStopFloor_Cr = mStopFloor_Pr = INITIAL_FLOORS - 1;
	
	// Elevator Count
	mElevatorCount_Cr = mElevatorCount_Pr = INITIAL_ELEVATORS;
	
	// Own Elevator Passengers
	mOwnElevatorPassengers_Cr = mOwnElevatorPassengers_Pr = INITIAL_PASSENGERS;
	
	// Transfers to level up
	mTransfersToLevelUp_Cr = mTransfersToLevelUp_Pr = INITIAL_PASSENGERS - 1;
	
	// Possible transfers
	mTransfersPossible_Cr = mTransfersPossible_Pr = (UInt8)truncf(mTransfersToLevelUp_Cr * POSSIBLE_TRANSFERS_MULTIPLIER);
	
	// Slots available for transfers
	mSlots_Cr = mSlots_Pr = mTransfersToLevelUp_Cr + MAX( truncf(STARTING_SLOT_BUFFER - wCalcLevel * SLOT_LEVEL_MULTIPLIER), 0);
	
	// CEO stops
	mStopsByCEO_Cr = mStopsByCEO_Pr = MAX(1, truncf(mFloors_Cr / CEO_STOP_DIVISOR));
	
	// CEO stop time
	mStopTimeByCEO_Cr = mStopTimeByCEO_Pr = (float)CEO_STOP_TIME_MAX_SECONDS;
	
	// Stop time by all transfer elevators except the CEO
	mStopTime = MAX(MIN_PAUSE_AT_FLOOR + (level - 1) * TRANSFER_PAUSE_INCREMENT, MAX_PAUSE_AT_FLOOR);
    
    // Elevator speed increases with later levels
    mElevatorSpeed_Cr = mElevatorSpeed_Pr = BUTTON_MIN_SPEED;
	
	// Bonuses
	mBonuses_Cr = mBonuses_Pr = (wCalcLevel < BONUSES_BEGIN_AT_LEVEL) ?  0 : RANDBETWEEN(1,MAX_BONUSES_PER_LEVEL);
	
	// Odd Transfers to Level Up?
	mIsOddTransferToLevelUp_Cr = mIsOddTransferToLevelUp_Pr = (mTransfersToLevelUp_Cr % 2 == 0) ? NO : YES;
	
	// p(Odd) (why is this five and not a #define ? )
	mpOdd_Cr = mpOdd_Pr = (wCalcLevel % 5 == 0) ? 0.1f : ODD_START_PERCENTAGE;
	
	// p(Odd) Actual
	mpOddActual_Cr = mpOddActual_Pr = (mIsOddTransferToLevelUp_Cr) ? mpOdd_Cr : (1 - mpOdd_Cr);
	
	// p(Even) (why is this five and not a #define ? )
	mpEven_Cr = mpEven_Pr = (wCalcLevel % 5 == 0) ? 0.1f : EVEN_START_PERCENTAGE;
	
	// p(Even) Actual
	mpEvenActual_Cr = mpEvenActual_Pr = (mIsOddTransferToLevelUp_Cr) ? (1 - mpEven_Cr) : mpEven_Cr;
	
	UInt8 wLevelsToGo = level - 1;
	wCalcLevel++;
	
	while(wLevelsToGo > 0)
	{
		// Level
		mLevel_Cr = mLevel_Pr + 1;
		
		// Floors
		if(wCalcLevel % LEVEL_PASSENGER_BUMP_DIVISOR == 0)
			mFloors_Cr = MROUND( truncf(mFloors_Pr * (1 + FLOOR_INCREMENT_FOR_PASSENGER_BUMP)),10);
		else
			mFloors_Cr = MROUND( truncf(mFloors_Pr * (1 + FLOOR_INCREMENT_PERCENT)),10);
		
		// Elevator count
		//=IF( MOD(A7,Const!$B$16) = 0,   MIN(H4+3,Const!$B$1),  H4 )
		if( wCalcLevel % ELEVATOR_BUMP_DIVISOR == 0 )
		{
			mElevatorCount_Cr = MIN(mElevatorCount_Pr + ELEVATOR_BUMP_INCREMENT, MAX_ELEVATORS);
		}
		else
		{
			// Current same as the previous
			mElevatorCount_Cr = mElevatorCount_Pr;
		}
		
		// Start Floor
		mStartFloor_Cr = mStopFloor_Cr + 1;
		
		// Stop Floor
		mStopFloor_Cr = mFloors_Cr + mStartFloor_Cr - 1;
		
		// Own Elevator Passengers
		mOwnElevatorPassengers_Cr = (wCalcLevel % LEVEL_PASSENGER_BUMP_DIVISOR == 0) ? mOwnElevatorPassengers_Pr + LEVEL_PASSENGER_BUMP_DIVISOR : mOwnElevatorPassengers_Pr + 2;
		
		// Transfers to level up
		mTransfersToLevelUp_Cr = mOwnElevatorPassengers_Cr - 1;
		
		// Possible transfers
		mTransfersPossible_Cr = (UInt8)truncf(mTransfersToLevelUp_Cr * POSSIBLE_TRANSFERS_MULTIPLIER);
		
		// Slots available for transfers
		mSlots_Cr = mTransfersToLevelUp_Cr + MAX( truncf(STARTING_SLOT_BUFFER - SLOT_LEVEL_MULTIPLIER), 0);
		
		// CEO stops
		mStopsByCEO_Cr = MAX(1, truncf( mFloors_Cr/CEO_STOP_DIVISOR ));
												 
		// CEO stop time
		mStopTimeByCEO_Cr = MAX(CEO_STOP_TIME_MIN_SECONDS,mStopTimeByCEO_Pr - (mStopsByCEO_Cr * FLOOR_INCREMENT_FOR_PASSENGER_BUMP));
        
        // Elevator speed
        BOOL wLevelBump = (mLevel_Cr % BUTTON_SPEED_FLOOR_DIVISOR == 0);
        UInt8 wLevelBumpSpeed = wLevelBump ? mElevatorSpeed_Pr + 1 : mElevatorSpeed_Pr;
        mElevatorSpeed_Cr = MIN(BUTTON_MAX_UP_VALUE, wLevelBumpSpeed);
		
		// Odd Transfers to Level Up?
		mIsOddTransferToLevelUp_Cr = (mTransfersToLevelUp_Cr % 2 == 0) ? NO : YES;
		
		// p(Odd) (why is this five and not a #define ? )
		mpOdd_Cr = (wCalcLevel % 5 == 0) ? mpOdd_Pr - 0.1f : mpOdd_Pr;
		
		// p(Odd) Actual
		mpOddActual_Cr = (mIsOddTransferToLevelUp_Cr) ? mpOdd_Cr : 1 - mpOdd_Cr;
		
		// p(Even) (why is this five and not a #define ? )
		mpEven_Cr = (wCalcLevel % 5 == 0) ? mpEven_Pr - 0.1f : mpEven_Pr;
		
		// p(Even) Actual
		mpEvenActual_Cr = (mIsOddTransferToLevelUp_Cr) ? 1 - mpEven_Cr : mpEven_Cr;
		
        mBonuses_Cr = (wCalcLevel < BONUSES_BEGIN_AT_LEVEL) ?  0 : RANDBETWEEN(1,MAX_BONUSES_PER_LEVEL);
		
		// Assign current values to the previous since they're no longer needed
		mLevel_Pr = mLevel_Cr;
		mFloors_Pr = mFloors_Cr;
		mElevatorCount_Pr = mElevatorCount_Cr;
		mStartFloor_Pr = mStartFloor_Cr;
		mStopFloor_Pr = mStopFloor_Cr;
		mOwnElevatorPassengers_Pr = mOwnElevatorPassengers_Cr;
		mTransfersToLevelUp_Pr = mTransfersToLevelUp_Cr;
		mTransfersPossible_Pr = mTransfersPossible_Cr;
		mSlots_Pr = mSlots_Cr;
		mStopsByCEO_Pr = mStopsByCEO_Cr;
		mStopTimeByCEO_Pr = mStopTimeByCEO_Cr;
		mBonuses_Pr = mBonuses_Cr;
		mIsOddTransferToLevelUp_Pr = mIsOddTransferToLevelUp_Cr;
		mpOdd_Pr = mpOdd_Cr;
		mpOddActual_Pr = mpOddActual_Cr;
		mpEven_Pr = mpEven_Cr;
		mpEvenActual_Pr = mpEvenActual_Cr;
		mElevatorSpeed_Pr = mElevatorSpeed_Cr;
        
		wLevelsToGo--;
		wCalcLevel++;
	}
	
	// Now calculate the individual elevator slots
	// -------------------------------------------
	// Level
	// Level up transfers
	// Possible transfers
	// Real sum
	// Solvable
	// p(Odd)
	// p(Even)
	// Elevator count
	// Max allowable
	// Max allowable is odd
	// Adjustment value
	BOOL wLevelUpIsOdd = ISODD(mTransfersToLevelUp_Cr);
	UInt8 wPossibleTransfers = (UInt8)truncf(mTransfersToLevelUp_Cr * POSSIBLE_TRANSFERS_MULTIPLIER);
	UInt8 wElevatorCount = mElevatorCount_Cr;

	UInt8 wMaxAllowedPerEl = (UInt8)ceilf(wPossibleTransfers/wElevatorCount);
	
	UInt8 wLevelAdjustmentValue = wPossibleTransfers;
	
	for(UInt8 i = 0; i < wElevatorCount; i++)
	{
		NSNumber *wVal;
		UInt8 wResult = 0;
		
		if(i == 0)
		{
			// Prime the first elevator with even or odd				
			wVal = (wLevelUpIsOdd) ? [NSNumber numberWithUnsignedChar:1] : [NSNumber numberWithUnsignedChar:2];
			[mElevatorPassengers replaceObjectAtIndex:0 withObject:wVal];
			wResult = [wVal charValue];
		}
		else 
		{
			UInt8 wOddOrEven = 0;
			// All subsequent elevators are calculated the same way
			UInt8 wRandBetween1andMaxAllowed = RANDBETWEEN(1,wMaxAllowedPerEl);
			
			if(CCRANDOM_0_1() <= mpOddActual_Cr)
				wOddOrEven = ODD(wRandBetween1andMaxAllowed);
			else 
				wOddOrEven = EVEN(wRandBetween1andMaxAllowed);
			
			wResult = MIN(wOddOrEven, wMaxAllowedPerEl);
			[mElevatorPassengers replaceObjectAtIndex:i withObject:[NSNumber numberWithUnsignedChar:wResult]];
		}
		
		wLevelAdjustmentValue -= wResult;
	}
	
	// Now catch any adjustments to the elevator counts

	CCLOG(@"Still need to transfer %d adjustment slots", wLevelAdjustmentValue);
		// Leave the zero-index alone - its value must remain 1 or 2
		for(UInt8 i = 1; wLevelAdjustmentValue > 0; i++)
		{
			NSNumber* wVal = [mElevatorPassengers objectAtIndex:i];
			UInt8 wInc = [wVal charValue] + 1;
			wVal = [NSNumber numberWithChar:(char)wInc];
			[mElevatorPassengers replaceObjectAtIndex:i withObject:wVal];
			wLevelAdjustmentValue--;
			if(i + 1 == wElevatorCount)
				i = 1;
		}
	
#ifndef RELEASE
	CCLOG(@"------ calculateLevel (%d) ----------------", mLevel_Cr);
	CCLOG(@" %d possible transfers.", wPossibleTransfers);
	CCLOG(@" %d own passengers.", mOwnElevatorPassengers_Cr);
	CCLOG(@" Start/Stop Floors: %d / %d", mStartFloor_Cr, mStopFloor_Cr);
	CCLOG(@" %d transfer elevators", mElevatorCount_Cr);
    CCLOG(@" %d bonuses", mBonuses_Cr);
    CCLOG(@" Elevator Speed: %d", mElevatorSpeed_Cr);
	NSNumber *wPasDebug;
	for(UInt8 wEl = 0; wEl < mElevatorCount_Cr; wEl++)
	{
		wPasDebug = [mElevatorPassengers objectAtIndex:wEl];
		CCLOG(@"Elevator %d, Slots %d", wEl+1, [wPasDebug charValue]);
	}
	CCLOG(@"-------------------------------------------");
#endif
	
	// Assign the current values to the object's main properties
	self.level = mLevel_Cr;
	self.floors = mFloors_Cr;
	self.startFloor = mStartFloor_Cr;
	self.stopFloor = mStopFloor_Cr;
	self.numberOfElevators = mElevatorCount_Cr;
	
	self.passengers = mOwnElevatorPassengers_Cr;
	self.stopsByCEO = mStopsByCEO_Cr;
	self.stopTimeByCEO = mStopTimeByCEO_Cr;
	self.bonuses = mBonuses_Cr;
    self.elevatorSpeed = mElevatorSpeed_Cr;
}

-(UInt8) slotsForElevatorIndex:(UInt8)index
{
	NSNumber* wNum = [mElevatorPassengers objectAtIndex:index];
	return (UInt8)[wNum charValue];
}

-(Bonus) getRandomBonus
{
	float wRand = CCRANDOM_0_1();
    
    // Create range variables
    float wMin = 0.0f;
    float wMax = 0.0f;
    
    // Calculate heart 
    wMin = 0.001f;
    wMax = HEART_P;
    if( ISBETWEEN(wMin, wMax, wRand) )
        return kHeart;
    
    // Pension
    wMin = wMax;
    wMax = PENSION_P + wMin;
    if( ISBETWEEN(wMin, wMax, wRand) )
        return kPension;
    
    // Death
    wMin = wMax;
    wMax = DEATH_P + wMin;
    if( ISBETWEEN(wMin, wMax, wRand) )
        return kDeath;
    
    // Passenger
    wMin = wMax;
    wMax = PASSENGER_P + wMin;
    if( ISBETWEEN(wMin, wMax, wRand) )
        return kPassenger;
    
    // No Radar
    wMin = wMax;
    wMax = NO_RADAR_P + wMin;
    if( ISBETWEEN(wMin, wMax, wRand) )
        return kNoRadar;
    
    // Synergy
    wMin = wMax;
    wMax = SYNERGY_P + wMin;
    if( ISBETWEEN(wMin, wMax, wRand) )
        return kSynergy;
    
	return kNone;
}

-(UInt16) getBonusValue:(Bonus)b
{
	switch(b)
	{
		case kNone:
			return 0;
		case kHeart:
			return 1;
		case kPension:
			if(self.level == 1)
				return MIN_PENSION_BONUS;
			else 
			{
				UInt16 wTemp = MIN_PENSION_BONUS * (UInt16)(PENSION_BONUS_MULTIPLIER * self.level - 1);
				return MROUND(wTemp, 100);
			}
		case kDeath:
			return 0;
		case kPassenger:
			return 0;
		case kNoRadar:
			{
				float wTemp = truncf((self.floors * RADAR_FLOOR_HIDDEN_MULTIPLIER) + RADAR_FLOORS_HIDDEN_MIN);
				UInt16 wRet = MROUND(wTemp, 10);
				return wRet;
			}		
		case kSynergy:
			return SYNERGY_BONUS;
	}
	
	return 0;
}

-(NSString*) getBonusSprite:(Bonus)b
{
	switch(b)
	{
		case kNone:
			return nil;
		case kHeart:
			return @"heart.png";
		case kPension:
			return @"treasure.png";
		case kDeath:
			return @"skull-black.png";
		case kPassenger:
			return nil;
		case kNoRadar:
			return @"noradar.png";
		case kSynergy:
			return @"synergy.png";
	}
	
	return nil;	
}

#pragma mark Singleton Methods ________________________

+(GameLevelMaker*) sharedInstance
{
	if(mInstance)
		return mInstance;
	
    @synchronized(self)
    {
        if (mInstance == nil)
			mInstance = [[self alloc] init];
    }
    return mInstance;
}

-(id) init
{
	if( (self = [super init]) ) 
	{
		mInstance = self;
		// Initialize all the ivars
		mElevatorPassengers = [[CCArray arrayWithCapacity:MAX_ELEVATORS] retain];
	}
	
	return mInstance;
}

+(id) allocWithZone:(NSZone *)zone 
{
    @synchronized(self) 
	{
        if (mInstance == nil) 
		{
            mInstance = [super allocWithZone:zone];			
            return mInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

-(id) copyWithZone:(NSZone *)zone
{
    return self;
}

-(id) retain 
{
    return self;
}

-(unsigned) retainCount 
{
    return UINT_MAX;  // denotes an object that cannot be released
}

-(void) release 
{
    //do nothing
}

-(id) autorelease 
{
    return self;
}

@end
