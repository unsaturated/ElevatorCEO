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

#import "BoosterAnimation.h"

@implementation BoosterAnimation

+(id) initWithScalingFactor:(float)scale
{
	return [[[self alloc] initWithScaling:scale] autorelease];
}

-(id) initWithScaling:(float)scale
{
	if( (self = [self init]) )
	{
        [self initWithSpriteFrameName:@"burner.png"];
		[self setScalingFactor:scale];
	}
	
	return self;
}

-(id) init
{
	if( (self=[super init] )) 
	{
		// Initialize the scaling factor to 100% (1.0)
		mScalingFactor = 1.0f;
        mActivated = NO;
	
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
	[super dealloc];
}


-(void) setScalingFactor:(float)scale
{
    if(mActivated)
        return;
    
	mScalingFactor = clampf(scale, 0.1f, 1.0f);
}

-(void) burn:(BOOL)activate
{
    if(!mActivated && activate)
    {
       
        mActivated = activate;
        
         // Run startup action (visibility fade) and repeat scaling "forever"
        CCFiniteTimeAction* wVisUp = [CCFadeIn actionWithDuration:0.2f];
        CCFiniteTimeAction* wScaleDown = [CCScaleTo actionWithDuration:0.15f scaleX:(mScalingFactor * 0.85f) scaleY:(mScalingFactor * 0.6f)];
        CCFiniteTimeAction* wScaleUp = [CCScaleTo actionWithDuration:0.15f scaleX:(mScalingFactor * 1.0f) scaleY:(mScalingFactor * 1.0f)];
        CCRepeat* wForever = [CCRepeat actionWithAction:[CCSequence actionOne:wScaleDown two:wScaleUp] times:INT_MAX];
        
        // Stop all existing actions
        [self stopAllActions];
        [self runAction: [CCSpawn actions:wVisUp, wForever, nil]];
    }
    else if(mActivated && !activate)
    {
        // Run shutdown action (visibility fade)
        mActivated = activate;
        CCFiniteTimeAction* wVisDn = [CCFadeOut actionWithDuration:0.5f];
        [self runAction:wVisDn];
    }
}

@end
