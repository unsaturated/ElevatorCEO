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

#import "GamePlayFloorLayer.h"

@implementation GamePlayFloorLayer

-(id) init
{
	if( (self = [super init]) )
	{
		mFloorMin = 0;
		mFloorMax = 0;
        
        mResetting = NO;
		
		// Set the anchor to the bottom left point
		[self setAnchorPoint:CGPointZero];
        
        // Create the floor sprites individually
		mFloorSprites = [[CCArray array] retain];
		
		// Create the floor numbers individually
		mFontSprites = [[CCArray array] retain];
        
        		
		// Set to floor width and height
        // Switch floors per screen based upon the aspect ratio (iPhone 5)
        if([GameController sharedInstance].is16x9)
        {
            mFloorsPerScreen = FLOORS_PER_SCREEN_16x9;
            mNumLevelSprites = NUM_LEVEL_SPRITES_16x9;
            mLevelSpritesPerScreen = NUM_LEVEL_SPRITES_PER_SCREEN_16x9;
            [self setContentSize:CGSizeMake(ELEVATOR_SHAFT_WIDTH * NUM_ELEVATOR_SHAFTS - PLAY_AREA_MARGIN, NUM_LEVEL_SPRITES_16x9 * FLOOR_HEIGHT)];
        }
        else
        {
            mFloorsPerScreen = FLOORS_PER_SCREEN;
            mNumLevelSprites = NUM_LEVEL_SPRITES;
            mLevelSpritesPerScreen = NUM_LEVEL_SPRITES_PER_SCREEN;
            [self setContentSize:CGSizeMake(ELEVATOR_SHAFT_WIDTH * NUM_ELEVATOR_SHAFTS - PLAY_AREA_MARGIN, NUM_LEVEL_SPRITES * FLOOR_HEIGHT)];
        }

		
		// Initialize current position aboe the screen area
		// The sprites are stored from top to bottom, low index to high index
		float wStart = (mLevelSpritesPerScreen * FLOOR_HEIGHT) + FLOOR_HEIGHT;
		CGPoint wCurPosition = ccp(0,wStart);
		
		mLastWrapPosition = CGPointZero;
		mSpriteIndexTop = 0;
		mSpriteIndexBottom = mNumLevelSprites - 1;
		
		// Elevator should always begin at minimum floor
		mCanElevatorMoveUp = YES;
		mCanElevatorMoveDown = NO;
		
		// Initialize each sprite from top to bottom of the screen
		for (UInt8 i = 0; i < mNumLevelSprites; i++)
		{
			CCSprite *wSprite = [CCSprite spriteWithSpriteFrameName:@"floor.png"];
			[wSprite setAnchorPoint:CGPointZero];
			
			// Initialize the tag to zero, but use it later for the floor number
			wSprite.tag = 0;
			[mFloorSprites addObject: wSprite];
			[self addChild: [mFloorSprites lastObject] z:0];
			wSprite.position = wCurPosition;
			
			// Initialize the floor numbers to zero - they'll be set later
			CCLabelBMFont* l = [CCLabelBMFont labelWithString:@"0" fntFile:[GameController selectFont:kDroidSansBold12White forceDefault:YES]];
			[mFontSprites addObject:l];
			l.position = ccp(ELEVATOR_SHAFT_WIDTH / 2.0f, (FLOOR_HEIGHT / 2.0f) + FLOOR_BOTTOM_GAP);
			[wSprite addChild:[mFontSprites lastObject] z:1 tag:i];
			
			// Add the size of the floor to position the next sprite
			wCurPosition = ccpAdd(wCurPosition, ccp(0,-FLOOR_HEIGHT)); 
			
			// Don't show the top and bottom sprites displayed outside the screen resolution
			if( (i < 2) || (i > mLevelSpritesPerScreen + 1) )
				wSprite.visible = NO;
		}
		
		// The level divider is part of the layer but only displayed when near the max floor 
		mLevelDivider = [CCSprite spriteWithSpriteFrameName:@"level-divider.png"];
		[mLevelDivider setAnchorPoint:CGPointZero];
		[self addChild:mLevelDivider z:3];
		mLevelDivider.visible = NO;

		self.isTouchEnabled = NO;
		
		// We need to do additional processing, so schedule updates
		[self scheduleUpdate];
		
		mSpeed = 0;
		mPrevPosition = self.position;
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

- (void) dealloc
{
	[mFloorSprites dealloc];
	[mFontSprites dealloc];
	CCLOG(@"---DEALLOC %@", self);
	[super dealloc];
}

- (void) onEnterTransitionDidFinish
{
	// Scene is fully visible so it's okay to display the wrapping sprites
	for (UInt8 i = 0; i < mNumLevelSprites; i++)
	{
		CCSprite *wSprite = [mFloorSprites objectAtIndex:i];
		wSprite.visible = YES;
	}
	
	[super onEnterTransitionDidFinish];
}

- (void) onExit
{
	[self unscheduleUpdate];
	[super onExit];
}

@synthesize floorMin = mFloorMin;

@synthesize floorMax = mFloorMax;

-(void) setFloorMin:(UInt16)minValue max:(UInt16)maxValue
{
	// ---------------
	// Easier to assume this is a "reset" type of function that clears all the iVars
	// and gets the game ready for a new level
    self.position = ccp(PLAY_AREA_MARGIN, 0);
	
	// Initialize current position aboe the screen area
	// The sprites are stored from top to bottom, low index to high index
	float wStart = (mLevelSpritesPerScreen * FLOOR_HEIGHT) + FLOOR_HEIGHT;
	CGPoint wCurPosition = ccp(0,wStart);
	
	mLastWrapPosition = CGPointZero;
	mSpriteIndexTop = 0;
	mSpriteIndexBottom = mNumLevelSprites - 1;
	
	// Elevator should always begin at minimum floor
	mCanElevatorMoveUp = YES;
	mCanElevatorMoveDown = NO;
	
	// Always start at zero
	mPrevPosition = CGPointZero;
	mSpeed = 0;
    mMove = ccp(0,0);
    
    mFloorMin = minValue;
	mFloorMax = maxValue; 

    mLevelDivider.visible = NO;

	// Initialize each sprite from top to bottom of the screen
	for (UInt8 i = 0; i < mNumLevelSprites; i++)
	{	
		CCSprite *wSprite = [mFloorSprites objectAtIndex:i];
		wSprite.position = wCurPosition;
        wSprite.tag = 0;

		// Add the size of the floor to position the next sprite
		wCurPosition = ccpAdd(wCurPosition, ccp(0,-FLOOR_HEIGHT)); 
	}
	
    
	// The floors will be numbered from top to bottom
	UInt16 wFloorNumber = mFloorMin + mFloorsPerScreen + 1;
	
	for (UInt8 i = 0; i < mNumLevelSprites; i++)
	{
		CCLabelBMFont *wLabel = [mFontSprites objectAtIndex:i];
		[wLabel setString:[NSString stringWithFormat:@"%i", wFloorNumber]];
		CCSprite *wFloorSprite = [mFloorSprites objectAtIndex:i];
		wFloorSprite.tag = wFloorNumber;
		wFloorNumber--;
	}
	
	mFloorMaxY = -(FLOOR_HEIGHT * ((mFloorMax - mFloorMin) - mFloorsPerScreen + 2));
}

@synthesize canElevatorMoveUp = mCanElevatorMoveUp;

@synthesize canElevatorMoveDown = mCanElevatorMoveDown;

-(void) update: (ccTime) dt
{	
    if(mResetting)
        return;
    
	// Distance = rate * time
	CGPoint wMoveDist = ccpMult(mMove, dt);
	
	// Setup logic to test for movement
	float wMoveDiff = 0.0f;

	if(!ccpFuzzyEqual(self.position, mPrevPosition, 0.50f))
	{
		wMoveDiff = self.position.y - mPrevPosition.y;
		mPrevPosition = self.position;
	}
	
	// Speed can be set manually or via implicit movement
	if(mSpeed <= 0)
	{
		mMove = ccp(0.0f, wMoveDiff);
	}
	
	// Request indicators
	BOOL wRequestingDown = (mMove.y > 0.0f);
	BOOL wRequestingUp = (mMove.y < 0.0f);

	// Return quickly if not going up or down
	if(!wRequestingUp && !wRequestingDown)
		return;

	// Don't scroll past the bottom floor or top most floor + 1
	CGPoint wDiff = ccpAdd(self.position, wMoveDist);

	// Check for allowable movement (lowest floor)
	if(wDiff.y > 0.0f)
	{
		self.position = ccp(self.position.x, 0.0f);
		mCanElevatorMoveUp = YES;
		mCanElevatorMoveDown = NO;
	}
	else if(wDiff.y < mFloorMaxY)
	{
		// Check for allowable movement (highest floor, plus a margin)
		self.position = ccp(self.position.x, mFloorMaxY);
		mCanElevatorMoveUp = NO;
		mCanElevatorMoveDown = YES;
	}
	else
	{
		// Checks for all other movement (not near min/max of 
		mCanElevatorMoveDown = YES;
		mCanElevatorMoveUp = YES;
		self.position = ccpAdd(self.position, wMoveDist);
	}
	
	// Get local references to the top and bottom sprites, since those are rotated
	CCSprite *wTopSprite = [mFloorSprites objectAtIndex:mSpriteIndexTop];
	CCSprite *wBottomSprite = [mFloorSprites objectAtIndex:mSpriteIndexBottom];
	CCLabelBMFont *wTopLabel = [mFontSprites objectAtIndex:mSpriteIndexTop];
	CCLabelBMFont *wBottomLabel = [mFontSprites objectAtIndex:mSpriteIndexBottom];
	
	// Determine direction and whether sprite wrapping is necessary
	BOOL wElevatorGoingUp = (mLastWrapPosition.y > self.position.y); 
	BOOL wElevatorGoingDown = (mLastWrapPosition.y < self.position.y); 
	BOOL wFloorNeedsWrap = (abs((int)(self.position.y - mLastWrapPosition.y)) >= FLOOR_HEIGHT);
	BOOL wFloorNeedsAdjust = NO;
	
	// Determine the adjustment necessary to stop "floor creep"
	if(wElevatorGoingUp)
		wFloorNeedsAdjust = ((wTopSprite.position.y + self.position.y) <= mFloorsPerScreen * FLOOR_HEIGHT);
	if(wElevatorGoingDown)
		wFloorNeedsAdjust = ((wBottomSprite.position.y + self.position.y) >= 0);
	
	if(wFloorNeedsWrap || wFloorNeedsAdjust)
	{	
		mLastWrapPosition = ccp(self.position.x, self.position.y);
		
		if(wElevatorGoingUp || wElevatorGoingDown)
		{
			if(wElevatorGoingUp)
			{
				wBottomSprite.visible = NO;
				// Move sprites from bottom to top
				wBottomSprite.position = ccp(0, wTopSprite.position.y + FLOOR_HEIGHT);
				wBottomSprite.tag = wTopSprite.tag + 1;
				wBottomSprite.visible = YES;
				
				// Readjust top/bottom indexes
				mSpriteIndexTop = mSpriteIndexBottom;
				
				// Show the floor divider just above the maximum floor
				if(wBottomSprite.tag == mFloorMax)
				{
					mLevelDivider.position = ccpAdd(wBottomSprite.position, ccp(0, FLOOR_HEIGHT));
					mLevelDivider.visible = YES;
				}
							
				// We're moving up so only the bottom sprite needs updating since 
				// it's wrapped to the top position
				[wBottomLabel setString:[NSString stringWithFormat:@"%li", (long)wBottomSprite.tag]];
				
				// Wrap sprite indexes for proper circular references
				if(mSpriteIndexBottom - 1 < 0)
					mSpriteIndexBottom = mNumLevelSprites - 1;
				else
					mSpriteIndexBottom--;
			}
			else 
			{	
				wTopSprite.visible = NO;
				// Move sprites from top to bottom and adjust floor number accordingly
				wTopSprite.position = ccp(0, wBottomSprite.position.y - FLOOR_HEIGHT);
				wTopSprite.tag = wBottomSprite.tag - 1;
				wTopSprite.visible = YES;
				
				// Readjust top/bottom indexes
				mSpriteIndexBottom = mSpriteIndexTop;

				// We're moving down so only the top sprite needs updating since 
				// it's wrapped to the bottom position
                // Caught error when updated to newer CCLabelBMFont: the '-' negative character
                // was not supported, which means the tag was less than zero. Floors less than
                // zero should never be displayed so don't bother updating
                if(wTopSprite.tag >= 0)
                    [wTopLabel setString:[NSString stringWithFormat:@"%li", (long)wTopSprite.tag]];
				
				if( (mSpriteIndexTop + 1) > (mNumLevelSprites - 1) )
					mSpriteIndexTop = 0;
				else
					mSpriteIndexTop++;
			}
		}	
	}
}

-(void) moveSpeed:(float) speed directionDown:(BOOL)down
{
	if(speed > 0)
	{
		if(down) 
			mMove = ccp(0,  (speed * FLOOR_HEIGHT));
		else
			mMove = ccp(0,  -(speed * FLOOR_HEIGHT));
	}
	else 
	{
		mMove = CGPointZero;
	}
	
	mSpeed = speed;
}

-(UInt16) floorFromPosition:(CGPoint)pos
{
	CCSprite* wFloor;
	float wTopY, wBtmY = 0.0f;
	
	CCARRAY_FOREACH(mFloorSprites, wFloor)
	{
		wTopY = self.position.y + wFloor.position.y + FLOOR_HEIGHT;
		wBtmY = self.position.y + wFloor.position.y;

		if( (pos.y >= wBtmY) && (pos.y <= wTopY) )
		{
			// Found the floor sprite for that position, now get its floor number
			// which happens to be assigned to the tag property
			return (UInt16)wFloor.tag;
		}
	}
	
	// Probably shouldn't get here but it's necessary
	return 0;
}

-(float) distanceToFloorBtm:(UInt16)floor atPosition:(CGPoint)pos
{
	CCSprite* wFloor;
	float wBtmY = 0.0f;
	
	CCARRAY_FOREACH(mFloorSprites, wFloor)
	{
		if(wFloor.tag == floor)
		{
			wBtmY = self.position.y + wFloor.position.y;
			return (wBtmY - pos.y);
		}
	}
	return 0.0f;
}

-(void) reset:(UInt16)minValue max:(UInt16)maxValue;
{
    mResetting = YES;
    
    [self setFloorMin:minValue max:maxValue];
    
    mResetting = NO;
}

@end
