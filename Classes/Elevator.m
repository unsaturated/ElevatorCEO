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

#import "Elevator.h"
#import "CCTouchDispatcher.h"

@implementation Elevator

/**
 * Create the objects used by the elevator.
 */
-(id) init
{
	if( (self=[super init] )) 
	{		
		// Default visibility as most scenes likely don't need them immediately visible
		self.visible = NO;
		
		// Start all elevators on floor 0
		mFloor = 0;
		
		mFloorGoingTo = 0;
        
        mTouched = NO;
		
		mIsOwnElevator = NO;
		
		mMove = CGPointZero;
		
		mMovementDir = kStopped;
        
        mBoosterScalingFactor = 1.0f;
        
        // Set the pension reward text size 
        mPensionReward = [CCLabelBMFont labelWithString:@"0" fntFile:[GameController selectFont:kDroidSansBold28White forceDefault:YES]];
        mPensionReward.visible = NO;
        [self addChild:mPensionReward z:1000];
        
        // Localize the pension reward text
		mFormatter = [[[NSNumberFormatter alloc] init] retain];
		[mFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[mFormatter setMaximumFractionDigits:0];
	}
	return self;
}

- (void) dealloc
{
    [mFormatter release];
	[super dealloc];
}

- (void) onExit
{
	//[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

#pragma mark Touch Handling _________________________________

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event 
{
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event 
{
	// Detect if the touch is within the bounding box of the elevator
	CGRect wElevatorRect = [mCar boundingBox];
	
	CGPoint convertedCarLocation = [self convertTouchToNodeSpace:touch];
	if (CGRectContainsPoint(wElevatorRect, convertedCarLocation)) 
	{
		[self touched];
	}
}

-(void) touched
{
	// Derived classes can handle touches differently but they should always 
	// call the base class
	
	if(self.isBoosterBurning)
		[self burnBooster:NO];
	else
		[self burnBooster:YES];
}

-(float) halfCarHeight
{
	return mCar.contentSize.height / 2.0f;
}

@synthesize movement = mMove;

#pragma mark IElevator Implementation _______________________

@synthesize isOwnElevator = mIsOwnElevator;

@synthesize isCeoElevator;

@synthesize passengersOnboard = mPassengersOnboard;

@synthesize passengerCapacity = mPassengerCapacity;

-(void) initializeLevel
{
	
}

-(void) initializePassengers:(UInt8)count
{
	mPassengersOnboard = count;
	[mLabelPassengers setString:[[NSNumber numberWithInt:count] stringValue]];
}

-(void) removePassengers:(UInt8)passengers
{
	
}

-(void) addPassengers:(UInt8)passengers
{
	mPassengersOnboard += passengers;
	[mLabelPassengers setString:[NSString stringWithFormat:@"%d", mPassengersOnboard]];
}

@synthesize floor = mFloor;

@synthesize floorMin = mFloorMin;

@synthesize floorMax = mFloorMax;

@synthesize floorGoingTo = mFloorGoingTo;

@synthesize movementDir = mMovementDir;

-(void) burnBooster:(BOOL)activate
{
	mBooster.visible = activate;
	[mBooster burn:activate];
	mBoosterBurning = activate;
}

@synthesize isBoosterBurning = mBoosterBurning;

-(void) setFloorMin:(UInt16)minValue max:(UInt16)maxValue
{
	mFloorMin = minValue;
	mFloorMax = maxValue;
}

-(void) animatePension:(float)amount
{
    // Initialize location
    mPensionReward.position = ccp(mCar.position.x, mCar.position.y + 5);
    
    // Initialize color
    [mPensionReward setColor:ccc3(255, 255, 255)];
    
    // Initialize size
    [mPensionReward setScale:0.3f];
    
    // Initialize text
    NSString* formatted = [mFormatter stringFromNumber:[NSNumber numberWithFloat:amount]];
    [mPensionReward setString:[GameController convertToAscii:formatted]];
    
    // Initialize visibility
    mPensionReward.visible = YES;
    
    // Animate to new location, size, and color
    CCScaleTo *wScale = [CCScaleTo actionWithDuration:PENSION_ANIMATION_SEC scale:2.0f];
    
    CCMoveBy *wMoveBy = [CCMoveBy actionWithDuration:PENSION_ANIMATION_SEC position:ccp(0, 20)];
    
    CCFadeOut *wFade = [CCFadeOut actionWithDuration:PENSION_ANIMATION_SEC];
    
    CCTintTo *wTint = [CCTintTo actionWithDuration:(PENSION_ANIMATION_SEC / 2.0f) red:0 green:255 blue:0];
    
    [mPensionReward runAction:[CCSpawn actions:wScale,wMoveBy,wFade,wTint,nil]];
}

@synthesize shaft;

@end
