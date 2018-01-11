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

#import "ElevatorTimer.h"

@implementation ElevatorTimer

-(id) init
{
	if( (self=[super init] )) 
	{
		// Initialize the time remaining to 100%
		mPercentRemain = 100.0f;
		
		// Create the array of sprites
		mBars = [[CCArray array] retain];
		
		// Initialize current position
		CGPoint wCurPosition = ccp(0,0);
		
		// NUM_BARS_TRANSFER_TIME
		for (UInt8 i = 0; i < NUM_BARS_TRANSFER_TIME; i++) 
		{
			CCSprite *wSprite = [CCSprite spriteWithSpriteFrameName:@"transfertime.png"];
			wSprite.visible = NO;
			[wSprite setAnchorPoint:CGPointZero];
			[mBars addObject: wSprite];
			[self addChild: [mBars lastObject] z:1];
			wSprite.position = wCurPosition;
			wCurPosition = ccpAdd(wCurPosition, ccp(0,4));
		}
		
		[self setAnchorPoint:CGPointZero];
		
		CCSprite* wBar = [mBars lastObject];
		
		CGSize wSize = CGSizeMake(wBar.contentSize.width, wBar.contentSize.height);
		
		[self setContentSize:wSize];
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
	[mBars dealloc];
	[super dealloc];
}


-(void) setPercent:(float)percent
{
	mPercentRemain = clampf(percent, 0.0f, 100.0f);
	
	// Calculate which of the bars should be displayed
	// Activate each sprite individually when a new level is received
	// 100.0 / 5 = 20.0
	CCSprite *wSprite;
	UInt8 wIndex = 0;
	UInt8 wVisCount = 0;
	CCARRAY_FOREACH(mBars, wSprite)
	{
		float wPercentCutoff = wIndex * (100.0f / NUM_BARS_TRANSFER_TIME);
		if(mPercentRemain > wPercentCutoff)
		{
			wVisCount++;
			wSprite.visible = YES;
		}
		else 
		{
			wSprite.visible = NO;
			[wSprite stopAllActions];
		}
		wIndex++;
	}
}


@end
