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

#import "GameUpDownButton.h"

@implementation GameUpDownButton

+(id)initUpButton
{
	GameUpDownButton *wButton = [[[self alloc] init] autorelease];
	[wButton setUpDirection:YES];
	
	return wButton;
}

+(id)initDownButton
{
	GameUpDownButton *wButton = [[[self alloc] init] autorelease];
	[wButton setUpDirection:NO];
	
	return wButton;
}

-(id) init
{
	if( (self=[super init] )) 
	{
		// Handle touches but don't consume all of them
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
														 priority:0 
												  swallowsTouches:NO];
		
		[self setAnchorPoint:CGPointZero];
		mSumTouchTime = 0.0f;
		mCurrentValue = 0;
		mTouchDown = NO;
		[self scheduleUpdate];
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
    self.delegate = nil;
	[self unscheduleSelectors];
	[super dealloc];
}

-(void)unscheduleSelectors
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [self unscheduleUpdate];
    [self unscheduleAllSelectors];
}

-(void)setUpDirection: (BOOL) up
{
	if(up) 
	{
		mNormalSprite = [CCSprite spriteWithSpriteFrameName:@"up-off-game.png"];
		mTouchedSprite = [CCSprite spriteWithSpriteFrameName:@"up-on-game.png"];
		mIsUpButton = YES;
		mMinValue = 0;
		mMaxValue = BUTTON_MAX_UP_VALUE;
	}
	else 
	{
		mNormalSprite = [CCSprite spriteWithSpriteFrameName:@"down-off-game.png"];		
		mTouchedSprite = [CCSprite spriteWithSpriteFrameName:@"down-on-game.png"];
		mIsUpButton = NO;
		mMinValue = 0;
		mMaxValue = BUTTON_MAX_DOWN_VALUE;
	}
	
	// Normal sprite properties
	mNormalSprite.visible = YES;
	mNormalSprite.position = ccp(0,0);
	[self addChild:mNormalSprite z:0];
	
	// Touched sprite properties
	mTouchedSprite.visible = NO;
	mTouchedSprite.position = ccp(0,0);
	[self addChild:mTouchedSprite z:1];
	
	// Ensure the control size is updated accordingly
	[self setContentSize: mTouchedSprite.contentSize];
}

-(void)setPressIsAllowable: (BOOL) allowable
{
	mPressAllowable = allowable;
}

@synthesize delegate;

-(BOOL)isTouchInButton: (UITouch *) touch
{
	// Use the touched sprite, but it doesn't matter size both are the same size
	CGPoint wLoc = [self convertTouchToNodeSpace:touch];
	
	// Test if touch is outside radius of button
	CGPoint wCenter = CGPointZero;
	CGFloat wRadius = self.contentSize.width / 2.0f;
	CGFloat wDist = ccpDistance(wCenter, wLoc);

	return (wDist <= wRadius);
}

@synthesize isUpButton = mIsUpButton;

@synthesize value = mCurrentValue;

#pragma mark Touch Handling

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event 
{
    // Escape early if the game is paused
    if([GameController sharedInstance].isPaused)
        return YES;
    
	// Detect if the touch is within the bounding box of the button
    BOOL wValidTouch = [self isTouchInButton:touch];
    BOOL wAllowable = mPressAllowable && ![GameController sharedInstance].isPaused;
	
	if(wValidTouch && wAllowable)
	{
		mTouchedSprite.visible = YES;
		mTouchDown = YES;
	}
    else if(wValidTouch && !wAllowable)
    {
        [[AudioController sharedInstance] playSound:kInvalidElevatorButton];
    }

    return YES;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event 
{
	// Detect if the touch is within the bounding box of the button;
	// the button is no longer pressed.
	
	if ([self isTouchInButton:touch] && mPressAllowable) 
	{
		// Stop all events for an up/down 
		mNormalSprite.visible = YES;
		[mTouchedSprite stopAllActions];
		mTouchedSprite.visible = NO;
		mTouchDown = NO;
	}
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Detect if the touch is moved outside the bounding box of the button;
	// this would be the equivalent of lifting a finger off.
	
	if(![self isTouchInButton:touch]) 
	{
		// Stop all events for an up/down
		mTouchedSprite.visible = NO;
		[mTouchedSprite stopAllActions];
		mTouchDown = NO;
	}
}

-(void) update: (ccTime) dt
{
    // Exit early if pressing/tapping is not allowed
    if(!mPressAllowable)
    {
        // Stop all events for an up/down 
		mNormalSprite.visible = YES;
		[mTouchedSprite stopAllActions];
		mTouchedSprite.visible = NO;
		mTouchDown = NO;
    }
    
	UInt8 wPrevValue = mCurrentValue;
    
    mMaxValue = [GameLevelMaker sharedInstance].elevatorSpeed;
    
	if( (mSumTouchTime > 0.0f) && (mSumTouchTime <= BUTTON_MAX_TAP_TIME) && !mTouchDown)
	{
		mSumTouchTime = 0.0f;
		mCurrentValue = 0;
		
		// Considered a tap
        if (delegate && ([delegate respondsToSelector:@selector(buttonUpEvent:hold:)] || [delegate respondsToSelector:@selector(buttonDownEvent:hold:)])) 
        {
            [[AudioController sharedInstance] playSound:kTapElevatorButton];
            // Tell our delegate the button is tapped
            if(mIsUpButton)
                [delegate buttonUpEvent:YES hold:mCurrentValue];
            else
                [delegate buttonDownEvent:YES hold:mCurrentValue];
        }
	}
	
	if(mTouchDown)
		mSumTouchTime += dt;
	else 
	{
		mSumTouchTime = 0.0f;
		mCurrentValue = 0;
	}
	
	if( mSumTouchTime >= ((mCurrentValue + 1) * BUTTON_TIME_INTERVAL) && (mSumTouchTime > BUTTON_MAX_TAP_TIME ) )
	{
		if(mCurrentValue + 1 <= mMaxValue)
		{
			mCurrentValue++;
			[mTouchedSprite runAction:[CCBlink actionWithDuration:0.5f blinks:2]];
		}
	}
	
	if(mCurrentValue != wPrevValue)
	{
		// Considered a press
        if (delegate && ([delegate respondsToSelector:@selector(buttonUpEvent:hold:)] || [delegate respondsToSelector:@selector(buttonDownEvent:hold:)])) 
        {
            // Only start the sound effect at speed 1
            if(mCurrentValue == 1)
                [[AudioController sharedInstance] playSound:kElevatorStarting];
            
            // Tell our delegate the button is not tapped
            if(mIsUpButton)
                [delegate buttonUpEvent:NO hold:mCurrentValue];
            else
                [delegate buttonDownEvent:NO hold:mCurrentValue];
        }	        
	}
}

@end
