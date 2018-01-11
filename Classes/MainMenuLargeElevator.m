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

#import "MainMenuLargeElevator.h"

@implementation MainMenuLargeElevator

/**
 * Create the objects used by the elevator.
 */
-(id) init
{
	if( (self=[super init] )) 
	{
		// The blue elevator is the smallest
		mCar = [CCSprite spriteWithSpriteFrameName:@"el-red.png"];
		mCar.position = ccp(0, 0);
		[self addChild: mCar z:2];
		
		// Add some fire
        mBooster = [BoosterAnimation initWithScalingFactor:1.0f];
        [mBooster setAnchorPoint:CGPointMake(0.5f, 1.0f)];
		mBooster.position = ccp(0, -30);
		[self addChild: mBooster z:1];
		[self burnBooster:YES];
		
		// Ensure scale works as expected (around 0,0)
		[self setAnchorPoint:CGPointZero];
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

-(void) prepareDemo
{
	// Start as a much smaller version of the elevator
	self.scale = 0.05f;
	
	self.position = mStartDemoPoint;
	self.visible = YES;
	
	id wActionTo = [CCMoveTo actionWithDuration: mDuration position:mStopDemoPoint];

	id wActionScale = [CCScaleTo actionWithDuration:mDuration*1.6f scale:2.2f];
	id wParallel = [CCSpawn actions:wActionTo, wActionScale, nil];
	mAction = [wParallel retain];
}

-(void) beginDemo
{
    [[AudioController sharedInstance] playSound:kBooster];
	[self runAction:mAction];
}

-(void) endDemo
{
	self.visible = NO;
	[self stopAllActions];
}

@end
