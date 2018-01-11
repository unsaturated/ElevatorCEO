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

#import "GameRadar.h"

@implementation GameRadar

-(id) init
{
	if( (self=[super init] )) 
	{
		[self setAnchorPoint:CGPointZero];
        
        if([GameController sharedInstance].is16x9)
        {
            // The iPhone 5 uses a common background image for radar and scores (82 x 152)
            CCSprite *wBg = [CCSprite spriteWithSpriteFrameName:@"radar-score-bg.png"];
            [wBg setAnchorPoint:CGPointZero];
            [self addChild:wBg];
        }
        else
        {
            // Add the background (82 x 120)
            CCSprite *wBg = [CCSprite spriteWithSpriteFrameName:@"radar-bg.png"];
            [wBg setAnchorPoint:CGPointZero];
            [self addChild:wBg];
        }
		
		mContents = [GameRadarContents node];
		mContents.position = ccp(mContents.clippingSize.width / 2.0f, mContents.clippingSize.height / 2.0f);
		[self addChild:mContents z:1];
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
	[super dealloc];
}

- (void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
}

@synthesize contents = mContents;

-(void) setShaftElevatorsOn: (UInt16) floor with:(CCArray*)array
{
	[mContents setShaftElevatorsOn:floor with:array];
}

-(void) setOwnElevator:(OwnGameElevator*)own ceoElevator:(CeoElevator*)ceo;
{
	[mContents setOwnElevator:own ceoElevator:ceo];
}

-(void) setFloorMinimum:(UInt16)min maximum:(UInt16)max
{
	[mContents setFloorMinimum:min maximum:max];
}

-(void) hideRadarForFloors:(UInt16)total
{
	[mContents hideRadarForFloors:total];
}

@end
