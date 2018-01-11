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

#import "ShaftControl.h"
#import "GameLevelMaker.h"
#import "GameController.h"
#import "TransferElevator.h"
#import "ElevatorMoveEnum.h"
#import "CeoElevator.h"

@implementation ShaftControl

-(id) init
{	
	if( (self = [super init]) )
	{
		mStartFloor = mStopFloor = mTotalElevators = mActiveElevators = 0;
		mElevators = [[CCArray arrayWithCapacity:MAX_ELS_IN_SHAFT] retain];
		
		// Add all the transfer elevators 
		for(UInt8 i = 0; i < MAX_ELS_IN_SHAFT; i++)
		{
			[mElevators addObject:[TransferElevator node]];
		}
		
		// The CEO's elevator is added later (manually) but only 
		// if this is the far-right elevator shaft
		
		[[CCScheduler sharedScheduler] scheduleUpdateForTarget:self priority:2 paused:NO];
		
		mStarted = NO;
		
		mShaftLocation = CGPointZero;
		
		mIsReadyForCEO = NO;
		mGetReadyForCEO = NO;
		mElsReadyForCEO = 0;
        
        mCeoPreviewFloor = 0;
        mGotCeoPreviewFloor = NO;
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

-(void) dealloc
{
	[mElevators removeAllObjects];
	[mElevators dealloc];
	[[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];
	[super dealloc];
}

@synthesize elevatorArray = mElevators;

@synthesize activeElevators = mActiveElevators;

-(BOOL) gettingReadyForCEO
{
    return mGetReadyForCEO;
}

@synthesize bonusCount;

-(void) setOwnElevator:(OwnGameElevator*)own ceoElevator:(CeoElevator*)ceo
{
	TransferElevator* wEl;
	CCARRAY_FOREACH(mElevators, wEl)
	{
		[wEl setOwnElevator:own];
	}
	
	if(ceo != nil)
		mCeoElevator = ceo;
}

-(void) setShaftLocation:(CGPoint)location;
{
	mShaftLocation = location;
	
	TransferElevator *wEl;
	CCARRAY_FOREACH(mElevators, wEl)
	{
		wEl.position = ccp(location.x, wEl.position.y);
	}
	
	if(mCeoElevator != nil)
	{
		mCeoElevator.position = ccp(location.x, mCeoElevator.position.y);
	}
}

-(void) addElevatorsToNode:(CCNode*)node ceoElevator:(CeoElevator*)ceo
{	
	TransferElevator *wEl;
	CCARRAY_FOREACH(mElevators, wEl)
	{
		[node addChild:wEl z:2];
	}
	
	if(ceo != nil)
	{
		[node addChild:ceo z:2];
	}
}

-(void) setActiveElevators:(UInt8)count
{
	if(count <= MAX_ELS_IN_SHAFT)
	{
		mTotalElevators = count;
		mActiveElevators = count;
	}
}

-(void) clearForCEO
{
    if(!mGotCeoPreviewFloor)
    {
        // Be sure to pre-calculate the first stop of the CEO for the radar display
        UInt16 wInterMed = (UInt16)floorf((mCeoElevator.floorRangeMax - mCeoElevator.floor - MIN_FLOORS_BETWEEN_ELS) / (float)mCeoElevator.stopsRemaining) + mCeoElevator.floor;
        UInt16 wRandFloor = [ShaftControl randomMinFloor:(mCeoElevator.floor+1) maxFloor:wInterMed];
        CCLOG(@"####### Getting CEO ready max (%d), floor (%d), stops remain (%d), intermediate (%d), rand (%d)",mCeoElevator.floorRangeMax, mCeoElevator.floor, mCeoElevator.stopsRemaining, wInterMed, wRandFloor);        
        mCeoPreviewFloor = wRandFloor;
        mCeoElevator.floorGoingToPreview = wRandFloor;
        mGotCeoPreviewFloor = YES;
    }
    
	mGetReadyForCEO = YES;
}

@synthesize isReadyForCEO = mIsReadyForCEO;

-(void) initializeShaft
{
	mIsReadyForCEO = NO;
	mGetReadyForCEO = NO;
	mProcessingCEO = NO;
	mElsReadyForCEO = 0;
    mCeoPreviewFloor = UINT16_MAX;
    mGotCeoPreviewFloor = NO;
    	
	GameLevelMaker *maker = [GameLevelMaker sharedInstance];
	
	mStartFloor = maker.startFloor;
	mStopFloor = maker.stopFloor;
	
	TransferElevator* wEl;
	
	UInt8 wActiveEls = mActiveElevators;
		
	struct MinMaxFloor wShaftInit[wActiveEls];
	
	[ShaftControl floorDataMinMax:wShaftInit elevators:wActiveEls floorMin:mStartFloor floorMax:mStopFloor];

	
	Bonus wBonuses[MAX_BONUSES_PER_LEVEL];
	
	if(self.bonusCount > 0)
	{
		for (int b = 0; b < self.bonusCount; b++) 
			wBonuses[b] = [[GameLevelMaker sharedInstance] getRandomBonus];
		
		// We have the bonuses but wait until the active elevators are known
	}
	
	
    // Local loop variable for all elevators
    UInt8 i = 0;
    
    // Local variable for monitoring number of bonuses assigned
    UInt8 p = 0;
    
	// Set active elevators (and inactive) and assign their floors
	CCARRAY_FOREACH(mElevators, wEl)
	{
		if(wActiveEls > 0)
		{
			[wEl setFloorMin:mStartFloor max:mStopFloor];
			[wEl setFloorRangeMin:wShaftInit[i].minimum maximum:wShaftInit[i].maximum];
			CCLOG(@"Setting el min/max to (%d, %d)", wShaftInit[i].minimum, wShaftInit[i].maximum);
			UInt16 wRandFloor = wShaftInit[i].startFloor;
			[wEl setTo:wRandFloor];
            
            if(wEl.passengersOnboard == UINT8_MAX)
            {
                // Set the bonus and reset to a random passenger count between MIN and MAX_BONUS_PASSENGER
                [wEl setBonus:wBonuses[p]];
                if(wBonuses[p] == kPassenger)
                {
                    UInt8 wPassengerBonus = (UInt8)RANDBETWEEN(MIN_BONUS_PASSENGER, MAX_BONUS_PASSENGER);
                    [wEl initializePassengers:wPassengerBonus];
                }
                p++;
            }
            else
                 [wEl setBonus:kNone];

			wEl.activeInGame = YES;
			wActiveEls--;
		}
		else 
		{
			[wEl setFloorMin:mStartFloor max:mStopFloor];
			[wEl setBonus:kNone];
			wEl.activeInGame = NO;
		}
		i++;
	}
	
	// Now setup the CEO elevator (if it's relevant)
	if(mCeoElevator != nil)
	{
		[mCeoElevator setFloorMin:mStartFloor max:(mStopFloor + MIN_FLOORS_BETWEEN_ELS)];
		[mCeoElevator setFloorRangeMin:mStartFloor maximum:(mStopFloor + MIN_FLOORS_BETWEEN_ELS)];
		[mCeoElevator setTo:mStartFloor-1];
		mCeoElevator.totalStops = maker.stopsByCEO;
		mCeoElevator.stopsRemaining = maker.stopsByCEO;
		mCeoElevator.timeAtEachStop = maker.stopTimeByCEO;
		mCeoElevator.activeInGame = NO;
	}
}

-(void) reset
{
	mIsReadyForCEO = NO;
	mGetReadyForCEO = NO;
	mProcessingCEO = NO;
	mElsReadyForCEO = 0;
    mCeoPreviewFloor = UINT16_MAX;
    mCeoElevator.floorGoingToPreview = UINT16_MAX;
    mGotCeoPreviewFloor = NO;
	
	self.bonusCount = 0;
	
	[self setActiveElevators:0];
    
    BaseTransferElevator* wEl;
    
    // Set active elevators (an inactive) and assign their floors
	CCARRAY_FOREACH(mElevators, wEl)
	{
        [wEl initializeLevel];
        [wEl setBonus:kNone];
        wEl.activeInGame = NO;
    }
    
    // Also initialize the CEO
    [mCeoElevator initializeLevel];
}

-(void) update:(ccTime)dt
{
	TransferElevator* wEl;
	
	UInt8 wElsActive = 0;
	
	CCARRAY_FOREACH(mElevators, wEl)
	{
		if(!wEl.activeInGame)
			continue;
		else
			wElsActive++;
		
		// Check for elevators that are idle for the minimum duration
		BOOL wExceedsPause = (wEl.timeAtFloor >= [GameLevelMaker sharedInstance].stopTime);

		// Elevator is sitting idle for too long but should not move for CEO
		if(wExceedsPause && !mGetReadyForCEO)
		{
			BOOL wGoodFloor = NO;
			UInt16 wRandFloor = 0;
			while (!wGoodFloor)
			{
				wRandFloor = [ShaftControl randomMinFloor:wEl.floorRangeMin maxFloor:wEl.floorRangeMax];
				if(wRandFloor != wEl.floor)
				{	
					wGoodFloor = YES;
					[wEl moveTo:wRandFloor];
				}
			}
		}
		// Elevator should get ready for CEO and number of utilized elevators in shaft NOT equal to those ready for CEO
		else if(mGetReadyForCEO && (mActiveElevators > 0) )
		{			
			if(wEl.floorGoingTo != mStopFloor + 3)
			{
				// Update min/max so it can move to top
				[wEl setFloorMin:mStartFloor max:mStopFloor+2];
				[wEl moveTo:mStopFloor + 3 overrideMinMax:YES];
			}
			else if(wEl.floor == mStopFloor + 3)
			{
				wEl.activeInGame = NO;
			}
		}
	}
	
	if(wElsActive == 0)
		mIsReadyForCEO = YES;
	
	if(mProcessingCEO)
	{
		BOOL wTimeOK = (mCeoElevator.timeAtFloor >= mCeoElevator.timeAtEachStop);
		BOOL wFirstMove = (mCeoElevator.stopsRemaining == mCeoElevator.totalStops);
		BOOL wGoingToFloor = (mCeoElevator.floorGoingTo != mCeoElevator.floor);
		
		if( (wTimeOK || wFirstMove) && (!wGoingToFloor))
		{
			if(mCeoElevator.stopsRemaining > 0)
			{
                UInt16 wRandFloor = 0;
                if(mGotCeoPreviewFloor)
                    wRandFloor = mCeoPreviewFloor;
                else
                {
                    UInt16 wInterMed = (UInt16)floorf((mCeoElevator.floorRangeMax - mCeoElevator.floor - MIN_FLOORS_BETWEEN_ELS) / (float)mCeoElevator.stopsRemaining) + mCeoElevator.floor;
                    wRandFloor = [ShaftControl randomMinFloor:(mCeoElevator.floor+1) maxFloor:wInterMed];
                }
                [mCeoElevator moveTo:wRandFloor];
                //CCLOG(@"####### CEO min = %d, max = %d, but going to... %d", (mCeoElevator.floor+1), wInterMed, wRandFloor);
    
				mCeoElevator.stopsRemaining--;
			}
			else
			{
                // No more stops left, so it's "bye bye" CEO - the player ran out of opportunities
                mCeoElevator.floorGoingToPreview = UINT16_MAX;
                mGetReadyForCEO = NO;
				[mCeoElevator moveTo:mCeoElevator.floorRangeMax];
			}
		}
		else if(mCeoElevator.floor == mCeoElevator.floorRangeMax)
		{
			wEl.activeInGame = NO;
		}
	}
	
	if(mIsReadyForCEO && !mProcessingCEO)
	{
		if(mCeoElevator != nil)
		{
			mCeoElevator.activeInGame = YES;
			mProcessingCEO = YES;
			[mCeoElevator setTo:mStartFloor-1];
			[mCeoElevator moveTo:mStartFloor];
		}
	}
}

+(UInt16) randomMinFloor:(UInt16) min maxFloor:(UInt16) max
{
	return (UInt16)((arc4random() % (max-min+1)) + min);
}

+(void) floorDataMinMax:(struct MinMaxFloor*)data elevators:(UInt8)count floorMin:(UInt16)min floorMax:(UInt16)max
{
	UInt16 wStartFloor = 0;
	UInt16 wMinFloor = min;
	UInt16 wMaxFloor = max;
	UInt16 wMaxWithRange = 0;
	
	for(UInt8 i = 0; i < count; i++) 
	{
		if(i == 0)
		{
			wMinFloor = min;
			wMaxFloor = truncf( ((max - min) / count) - MIN_FLOORS_BETWEEN_ELS + min);
		}
		else 
		{
			wMinFloor = wMaxWithRange + MIN_FLOORS_BETWEEN_ELS;
			wMaxFloor = truncf( ((max - wMinFloor) / (count - i)) + wMinFloor );
		}
		
		wMaxWithRange = [ShaftControl randomMinFloor:(wMinFloor + MAX_FLOOR_DIFF) maxFloor:wMaxFloor];
		wStartFloor = [ShaftControl randomMinFloor:wMinFloor maxFloor:wMaxWithRange];
		data[i].minimum = wMinFloor;
		data[i].maximum = wMaxWithRange;
		data[i].startFloor = wStartFloor;
	}
}

@end