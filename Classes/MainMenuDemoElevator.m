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

#import "MainMenuDemoElevator.h"

@implementation MainMenuDemoElevator

+(id) initWithStartLocation:(CGPoint)a stopLocation:(CGPoint)b duration:(ccTime)seconds
{
	MainMenuDemoElevator *wObj = [[[self alloc] init] autorelease];
	[wObj setStart:a stop:b];
	[wObj setDuration:seconds];
	return wObj;
}

-(id) init
{
	if( (self=[super init] )) 
	{
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
	[super dealloc];
}

- (void) setStart:(CGPoint)a stop:(CGPoint)b
{
	mStartDemoPoint = a;
	mStopDemoPoint = b;
}

- (void) setDuration:(ccTime)seconds
{
	mDuration = seconds;
}

-(void) prepareDemo
{
	self.position = mStartDemoPoint;
	self.visible = YES;
	[self burnBooster:NO];
	
	// Demo actions with sequence
	id wActionTo = [CCMoveTo actionWithDuration: mDuration position:mStopDemoPoint];
	id wActionToEase = [CCEaseInOut actionWithAction: [[wActionTo copy] autorelease] rate: 2.0f];
	id wActionDelay = [CCDelayTime actionWithDuration:3.0f];
	id wActionReset = [CCMoveTo actionWithDuration: 0 position:mStartDemoPoint];
	id wSeq1 = [CCSequence actions:wActionToEase, wActionDelay, wActionReset, nil];
	
	CCRepeatForever *wRepeat = [CCRepeatForever actionWithAction: wSeq1];
	mAction = [wRepeat retain];	
}

-(void) beginDemo
{
	[self burnBooster:YES];
	[self runAction:mAction];
}

-(void) endDemo
{
	self.position = ccp(40, 200);
	self.visible = YES;
	[self stopAllActions];
}

@end
