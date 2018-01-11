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
#import "BonusEnumerations.h"
#import "CCArray+Extension.h"
#import "IElevator.h"

@interface GameLevelMaker : NSObject 
{
	@private
	
	// Members pertaining to Levels Worksheet
	UInt8 mLevel, mLevel_Cr, mLevel_Pr;

	UInt16 mFloors, mFloors_Cr, mFloors_Pr;
	
	UInt16 mStartFloor, mStartFloor_Cr, mStartFloor_Pr;
	
	UInt16 mStopFloor, mStopFloor_Cr, mStopFloor_Pr;
	
	UInt8 mOwnElevatorPassengers, mOwnElevatorPassengers_Cr, mOwnElevatorPassengers_Pr;
	
	UInt8 mTransfersToLevelUp_Cr, mTransfersToLevelUp_Pr;
	
	UInt8 mTransfersPossible_Cr, mTransfersPossible_Pr;
	
	UInt8 mSlots_Cr, mSlots_Pr;
	
	UInt8 mStopsByCEO, mStopsByCEO_Cr, mStopsByCEO_Pr;
	
	float mStopTimeByCEO, mStopTimeByCEO_Cr, mStopTimeByCEO_Pr;
	
	UInt8 mElevatorSpeed, mElevatorSpeed_Cr, mElevatorSpeed_Pr;
	
	UInt8 mBonuses_Cr, mBonuses_Pr;
	
	BOOL mIsOddTransferToLevelUp_Cr, mIsOddTransferToLevelUp_Pr;
	
	float mpOdd_Cr, mpOdd_Pr;
	
	float mpOddActual_Cr, mpOddActual_Pr;
	
	float mpEven_Cr, mpEven_Pr;
	
	float mpEvenActual_Cr, mpEvenActual_Pr;
	
	// Members pertaining to Els Worksheet
	UInt8 mElevatorCount, mElevatorCount_Cr, mElevatorCount_Pr;

	CCArray *mElevatorPassengers;
	
	float mStopTime;
}

#pragma mark Level Properties ________________________

@property (nonatomic) UInt8 level;

@property (nonatomic) UInt16 floors;

@property (nonatomic) UInt16 startFloor;

@property (nonatomic) UInt16 stopFloor;

@property (nonatomic) UInt8 passengers;

@property (nonatomic) UInt8 stopsByCEO;

@property (nonatomic) float stopTimeByCEO;

@property (nonatomic) UInt8 numberOfElevators;

@property (nonatomic) UInt8 bonuses;

@property (nonatomic) float stopTime;

@property (nonatomic) UInt8 elevatorSpeed;

#pragma mark Level Functions ________________________

/**
 * Performs all calculations for the current level. All properties
 * are updated after this function is called.
 * @param level Game level to calculate
 */
-(void) calculateLevel:(UInt8)level;

/**
 * Gets the number of starting slots for a transfer elevator
 * at the specified index.
 * @param index Index (0 to MAX_ELEVATORS-1)
 * @returns Number of slots 
 */
-(UInt8) slotsForElevatorIndex:(UInt8)index;

/**
 * Gets a random bonus based upon a random number and the 
 * probability of each bonus.
 * @returns Bonus enumeration
 */
-(Bonus) getRandomBonus;

/**
 * Gets a value for a particular bonus enumeration. The return 
 * type is typically an unsigned integer.
 * @param b Bonus type
 * @returns Bonus value
 */
-(UInt16) getBonusValue:(Bonus)b;

/**
 * Gets a sprite that represents the bonus enumeration.
 * @param b Bonus type
 * @returns New sprite instance (or nil if no image associated with Bonus)
 */
-(NSString*) getBonusSprite:(Bonus)b;

#pragma mark Singleton Methods ______________________

/**
 Gets the shared instance of the GameLevelMaker object.
 */
+(GameLevelMaker*) sharedInstance;

+(id) allocWithZone:(NSZone *)zone;

-(id) copyWithZone:(NSZone *)zone;

-(id) retain;

-(unsigned) retainCount;

-(void) release;

-(id) autorelease;

@end
