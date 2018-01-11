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

#import "GameSynergy.h"

@implementation GameSynergy

-(id) init
{
	if( (self=[super init] )) 
	{
		// Initialize the level to 100%
		mSynergyLevel = 100.0f;
		mBarsVisible = GRAY_SYNERGY_BARS;
		
		// Create the array of sprites
		mRedBars = [[CCArray array] retain];
		mYellowBars = [[CCArray array] retain];
		mGreenBars = [[CCArray array] retain];
		mGrayBars = [[CCArray array] retain];
		mAllColorBars = [[CCArray array] retain];
		
		// Initialize current position
		CGPoint wCurPosition = ccp(0,0);
		
		for (UInt8 i = 0; i < RED_SYNERGY_BARS; i++) 
		{
			CCSprite *wSprite = [CCSprite spriteWithSpriteFrameName:@"lifebar.png"];
            [wSprite setColor:ccc3(237, 39, 0)];
			wSprite.visible = NO;
            if([GameController sharedInstance].is16x9)
                [wSprite setScaleY:1.2f];
			[wSprite setAnchorPoint:CGPointZero];
			[mRedBars addObject: wSprite];
			[mAllColorBars addObject: wSprite];
			[self addChild: [mRedBars lastObject] z:1];
			wCurPosition = ccpAdd(wCurPosition, ccp(3,0));
			wSprite.position = wCurPosition;
		}
		
		for (UInt8 i = 0; i < YELLOW_SYNERGY_BARS; i++) 
		{
			CCSprite *wSprite = [CCSprite spriteWithSpriteFrameName:@"lifebar.png"];
            [wSprite setColor:ccc3(239, 255, 34)];
			wSprite.visible = NO;
            if([GameController sharedInstance].is16x9)
                [wSprite setScaleY:1.2f];
			[wSprite setAnchorPoint:CGPointZero];
			[mYellowBars addObject: wSprite];
			[mAllColorBars addObject: wSprite];
			[self addChild: [mYellowBars lastObject] z:1];
			wCurPosition = ccpAdd(wCurPosition, ccp(3,0));
			wSprite.position = wCurPosition;
		}
		
		for (UInt8 i = 0; i < GREEN_SYNERGY_BARS; i++) 
		{
			CCSprite *wSprite = [CCSprite spriteWithSpriteFrameName:@"lifebar.png"];
            [wSprite setColor:ccc3(17, 211, 63)];
			wSprite.visible = NO;
            if([GameController sharedInstance].is16x9)
                [wSprite setScaleY:1.2f];
			[wSprite setAnchorPoint:CGPointZero];
			[mGreenBars addObject: wSprite];
			[mAllColorBars addObject: wSprite];
			[self addChild: [mGreenBars lastObject] z:1];
			wCurPosition = ccpAdd(wCurPosition, ccp(3,0));
			wSprite.position = wCurPosition;
		}
		
		// Reset for gray bars
		wCurPosition = ccp(0,0);
		
		for (UInt8 i = 0; i < GRAY_SYNERGY_BARS; i++) 
		{
			CCSprite *wSprite = [CCSprite spriteWithSpriteFrameName:@"lifebar.png"];
            [wSprite setColor:ccc3(81, 81, 81)];
			wSprite.visible = YES;
            if([GameController sharedInstance].is16x9)
                [wSprite setScaleY:1.2f];
			[wSprite setAnchorPoint:CGPointZero];
			[mGrayBars addObject: wSprite];
			[self addChild: [mGrayBars lastObject] z:0];
			wCurPosition = ccpAdd(wCurPosition, ccp(3,0));
			wSprite.position = wCurPosition;
		}
		
		[self setAnchorPoint:CGPointZero];
		self.isTouchEnabled = NO;
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
	[mRedBars dealloc];
	[mYellowBars dealloc];
	[mGreenBars dealloc];
	[mGrayBars dealloc];
	[mAllColorBars dealloc];
	[super dealloc];
}

@synthesize synergyLevel = mSynergyLevel;

-(void) setSynergy:(float)level
{
	mSynergyLevel = clampf(level, 0.0f, 100.0f);
	
	// Calculate which of the 19 bars should be displayed
	// Activate each sprite individually when a new level is received
	// 100.0 / 19 = 5.2632 (roughly)
	CCSprite *wSprite;
	UInt8 wIndex = 0;
	UInt8 wVisCount = 0;
	CCARRAY_FOREACH(mAllColorBars, wSprite)
	{
		float wStartValue = wIndex * (100.0f / COUNT_SYNERGY_BARS);
		if(mSynergyLevel > wStartValue)
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
	
	UInt8 wLastBarsVisible = mBarsVisible;
	mBarsVisible = wVisCount;
	
	// If there are no yellow bars, it's time to go on alert
	if( (wVisCount <= RED_SYNERGY_BARS) && (mBarsVisible < wLastBarsVisible) && (wVisCount > 0) )
	{
		CCSprite *wLastRed = [mRedBars objectAtIndex:wVisCount-1];
		CCSprite *wGray;
		float wDelay = 0.0f;
		for(UInt8 j = 1; j <= GRAY_SYNERGY_BARS; j++)
		{
			wGray = [mGrayBars objectAtIndex:GRAY_SYNERGY_BARS - j];
			[wGray runAction:[CCSequence actions:[CCDelayTime actionWithDuration:wDelay],
							  [CCFadeOut actionWithDuration:0.1f],
							  [CCFadeIn actionWithDuration:0.1f],
							  nil]];
			wDelay += 0.05f;
		}
		
        // Play low synergy alert only if this is the first red bar
        if(wLastBarsVisible > RED_SYNERGY_BARS)
            [[AudioController sharedInstance] playSound:kLowSynergyWarning];
        
		[wLastRed runAction:[CCBlink actionWithDuration:10.0f blinks:20]];
	}
	
	// Stop all the previously running actions for red bars
	if( (mBarsVisible > wLastBarsVisible) && (mBarsVisible <= RED_SYNERGY_BARS + 1) )
	{
		for(UInt8 wIndex = 0; wIndex < wLastBarsVisible; wIndex++)
		{
			CCSprite *wLastRed = [mRedBars objectAtIndex:wIndex];
			[wLastRed stopAllActions];
		}
	}
}

@end
