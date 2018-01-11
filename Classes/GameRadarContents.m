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

#import "GameRadarContents.h"
#import "GameController.h"
#import "CeoElevator.h"

@implementation GameRadarContents

-(id) init
{
	if( (self = [super init]) )
	{
		[self setAnchorPoint:CGPointZero];
		[self scheduleUpdate];
		
		mShaft0X = mShaft1X = mShaft2X = mShaft3X = mShaft4X = 0;
		
		mElevatorCountValid = 0;
		
		mFloorMin = mFloorMax = 0;
		
		mNumberOfFloorsToHide = mNumberOfFloorsToHideTotal = mLastOwnElevatorFloor = 0;

		// Actual size of radar background is 82x120.
		//
		// Each elevator is 9x9. 
		// We need a maximum of 5 horizontally and 6 vertically.
		// Minimum clipping size of 45x54.
		// Adding 3px between elevator horizontally gives min clip size: 57x110.
		// Removing 3px on top and bottom yields a final clip = 57x108
        
        // For iPhone 5, the same logic above applies and yields a final clip of 57x140
        
        // Add another 4pt vertical margin
		
        if([GameController sharedInstance].is16x9)
        {
            // iPhone 5
            mVisibleRect = CGRectMake(0.0f, 0.0f, 57.0f, 136.0f);
            mClippingSize = CGSizeMake(82.0f - mVisibleRect.size.width, 152.0f - mVisibleRect.size.height);
        }
        else
        {
            // Standard display
            mVisibleRect = CGRectMake(0.0f, 0.0f, 57.0f, 104.0f);
            mClippingSize = CGSizeMake(82.0f - mVisibleRect.size.width, 120.0f - mVisibleRect.size.height);
        }
		
		// Add the width of each elevator plus 3px as spacing
		float wSpacing = 3.0f + 8.0f; 
		
		mShaft0X = 0.0f;
		mShaft1X = mShaft0X + wSpacing;
		mShaft2X = mShaft1X + wSpacing;
		mShaft3X = mShaft2X + wSpacing;
		mShaft4X = mShaft3X + wSpacing;
		
		mShaft0Sprites = [[CCArray arrayWithCapacity:1] retain];
		mShaft1Sprites = [[CCArray arrayWithCapacity:MAX_ELS_IN_SHAFT] retain];
		mShaft2Sprites = [[CCArray arrayWithCapacity:MAX_ELS_IN_SHAFT] retain];
		mShaft3Sprites = [[CCArray arrayWithCapacity:MAX_ELS_IN_SHAFT] retain];
		mShaft4Sprites = [[CCArray arrayWithCapacity:MAX_ELS_IN_SHAFT+1] retain];
		
		mCircleSprites = [[CCArray arrayWithCapacity:5] retain];
		
		mAllRadarSprites = [CCNode node];
		[self addChild: mAllRadarSprites z:2];
		
		mRadarCountdownSprites = [CCNode node];
		[self addChild:mRadarCountdownSprites z:3];
		mRadarCountdownSprites.visible = NO;
		
		CCSprite *wSprite = nil;
		
		// Create shaft 1 elevator avatars (only the own elevator)
		wSprite = [CCSprite spriteWithSpriteFrameName:@"radar-blue.png"];
		wSprite.visible = NO;
		[wSprite setAnchorPoint:CGPointZero];
		[mShaft0Sprites addObject: wSprite];
		[mAllRadarSprites addChild:[mShaft0Sprites lastObject] z:1];
		wSprite.position = ccp(mShaft0X,0);
		
		// Shaft 1 elevators 
		for(UInt8 i = 0; i < MAX_ELS_IN_SHAFT; i++)
		{
			wSprite = [CCSprite spriteWithSpriteFrameName:@"radar-green.png"];
			wSprite.visible = NO;
			[wSprite setAnchorPoint:CGPointZero];
			[mShaft1Sprites addObject: wSprite];
			[mAllRadarSprites addChild: [mShaft1Sprites lastObject] z:1];
			wSprite.position = ccp(mShaft1X,0);
		}

		// Shaft 2 elevators 
		for(UInt8 i = 0; i < MAX_ELS_IN_SHAFT; i++)
		{
			wSprite = [CCSprite spriteWithSpriteFrameName:@"radar-green.png"];
			wSprite.visible = NO;
			[wSprite setAnchorPoint:CGPointZero];
			[mShaft2Sprites addObject: wSprite];
			[mAllRadarSprites addChild: [mShaft2Sprites lastObject] z:1];
			wSprite.position = ccp(mShaft2X,0);
		}
		
		// Shaft 3 elevators 
		for(UInt8 i = 0; i < MAX_ELS_IN_SHAFT; i++)
		{
			wSprite = [CCSprite spriteWithSpriteFrameName:@"radar-green.png"];
			wSprite.visible = NO;
			[wSprite setAnchorPoint:CGPointZero];
			[mShaft3Sprites addObject: wSprite];
			[mAllRadarSprites addChild: [mShaft3Sprites lastObject] z:1];
			wSprite.position = ccp(mShaft3X,0);
		}
		
		// Shaft 4 elevators 
		for(UInt8 i = 0; i < MAX_ELS_IN_SHAFT; i++)
		{
			wSprite = [CCSprite spriteWithSpriteFrameName:@"radar-green.png"];
			wSprite.visible = NO;
			[wSprite setAnchorPoint:CGPointZero];
			[mShaft4Sprites addObject: wSprite];
			[mAllRadarSprites addChild: [mShaft4Sprites lastObject] z:1];
			wSprite.position = ccp(mShaft4X,0);
		}
		
		// Create an extra elevator in Shaft 4 for the CEO
		wSprite = [CCSprite spriteWithSpriteFrameName:@"radar-red.png"];
		wSprite.visible = NO;
		[wSprite setAnchorPoint:CGPointZero];
		[mShaft4Sprites addObject: wSprite];
		[mAllRadarSprites addChild:[mShaft4Sprites lastObject] z:1];
		wSprite.position = ccp(mShaft4X,0);
        
        // And another in Shaft 4 for the CEO's preview location
        // Dim the color so it's obviously not the actual location
        wSprite = [CCSprite spriteWithSpriteFrameName:@"radar-red.png"];
        wSprite.visible = NO;
        [wSprite setColor:ccc3(200,200,200)];
        [wSprite setAnchorPoint:CGPointZero];
        [mShaft4Sprites addObject:wSprite];
        [mAllRadarSprites addChild:[mShaft4Sprites lastObject] z:1];
        wSprite.position = ccp(mShaft4X,0);
        [wSprite runAction:[CCRepeatForever actionWithAction:
                            [CCSequence 
                             actionOne:[CCFadeOut actionWithDuration:CEO_RADAR_FLASH_SEC] 
                             two:[CCFadeIn actionWithDuration:CEO_RADAR_FLASH_SEC]]]];
		
		
		// Floor countdown text
        mFloorsRemainLabel = [CCLabelBMFont labelWithString:@"" fntFile:[GameController selectFont:kDroidSans11White]];
		mFloorsRemainLabel.visible = NO;
		mFloorsRemainLabel.position = ccp(mVisibleRect.size.width / 2.0f + 8.0f, mVisibleRect.size.height / 2.0f);
		[mRadarCountdownSprites addChild:mFloorsRemainLabel z:3 tag:20];
		
		// Lock sprite
		mLockSprite = [CCSprite spriteWithSpriteFrameName:@"no-radar-lock.png"];
		// Middle of radar area plus 30 points higher vertically
		mLockSprite.position = ccp(mVisibleRect.size.width / 2.0f + 2.0f, mVisibleRect.size.height / 2.0f + 2.0f);
		mLockSprite.scale = 0.8f;
		[mRadarCountdownSprites addChild:mLockSprite z:3];
		
		// Circle sprites (6)
		float wRotation = -38.0f;
		for(UInt8 i = 0; i < 5; i++)
		{
			wSprite = [CCSprite spriteWithSpriteFrameName:@"circle-part.png"];
			[mCircleSprites addObject:wSprite];
			[mRadarCountdownSprites addChild:[mCircleSprites lastObject] z:4];
			wSprite.rotation = wRotation;
			wRotation += 71.5f;
			wSprite.position = ccp(mVisibleRect.size.width / 2.0f + 2.0f, mVisibleRect.size.height / 2.0f);
		}
		
		CCLOG(@"+++INIT %@", self);
	}
	return self;
}

-(void) dealloc
{
    [mShaft1 release];
	[mShaft2 release];
	[mShaft3 release];
	[mShaft4 release];
    
	[mShaft0Sprites release];
	[mShaft1Sprites release];
	[mShaft2Sprites release];
	[mShaft3Sprites release];
	[mShaft4Sprites release];	
    
	[mCircleSprites release];
	
    [super dealloc];
}

- (void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
}

-(void) visit 
{
    [self preVisitWithClippingRect:mVisibleRect];
    [super visit];
    [self postVisit];
}

-(void) update:(ccTime) dt
{	
	// Move the elevator avatars to their matching position
	// Use min/max floors as basis for 0-100% movement between lowest
	// y-position and highest.
    // 5 = number of shafts for transfer elevators + 1
	if(mElevatorCountValid >= 5)
	{
		// Local sprite to control all elevators
		CCSprite* wAvatar = nil;
		Elevator* wElevator = nil;

        // This used to have 108.0f (why?). It should have been mVisibleRect.size.height
		//float wPixPerFloor = (108.0f - self.clippingSize.height) / (mFloorMax - mFloorMin + 1);
		float wPixPerFloor = (mVisibleRect.size.height - self.clippingSize.height) / (mFloorMax - mFloorMin + 1);
		
		// Check for own elevator floor changes in case the radar is currently hidden and the 
		// floor countdown is ongoing
		if(mNumberOfFloorsToHide > 0)
		{
			if(mLastOwnElevatorFloor != mOwnEl.floor)
			{
				mLastOwnElevatorFloor = mOwnEl.floor;
				mNumberOfFloorsToHide--;
				float wPercentComplete = (float)(mNumberOfFloorsToHideTotal - mNumberOfFloorsToHide) / mNumberOfFloorsToHideTotal;
				
				[mFloorsRemainLabel setString:[NSString stringWithFormat:@"%i", mNumberOfFloorsToHide]];
				mFloorsRemainLabel.position = ccp(mVisibleRect.size.width / 2.0f, mVisibleRect.size.height / 2.0f);
				//[self rotateLockCircle];
				
				ccColor3B wColor = [GameRadarContents colorFromRedToGreen:wPercentComplete];
				
				CCSprite* wSprite;
				float wTime = 0.0f;
				CCARRAY_FOREACH(mCircleSprites, wSprite)
				{
					[wSprite runAction:[CCSequence actions:
										[CCDelayTime actionWithDuration:wTime],
										[CCTintTo actionWithDuration:0.0f red:wColor.r green:wColor.g blue:wColor.b],
										nil]];
					 wTime += 0.1f;
				}
				
				// Make the radar re-appear 
				if(mNumberOfFloorsToHide == 0)
				{
					[self runAction:[CCCallFunc actionWithTarget:self selector:@selector(showRadar)]];
				}			 
			}
		}
		else 
		{
			mLastOwnElevatorFloor = mOwnEl.floor;
		}

		
		// Handle the own elevator
		wAvatar = [mShaft0Sprites objectAtIndex:0];
		wAvatar.visible = mOwnEl.visible;
		if(mOwnEl.visible && !mOwnEl.deathSequencePlaying)
		{
			wAvatar.position = ccp(mShaft0X, (mOwnEl.floor - mFloorMin) * wPixPerFloor);
            [wAvatar setColor:ccc3(255, 255, 255)];
		}
        else if(mOwnEl.deathSequencePlaying)
        {
            [wAvatar setColor:ccc3(118,118,118)];
        }
		
		// Handle shaft1 elevators
		for(UInt8 i = 0; i < MAX_ELS_IN_SHAFT; i++)
		{
			wAvatar = [mShaft1Sprites objectAtIndex:i];
			wElevator = [mShaft1 objectAtIndex:i];
			if(wElevator.visible && wElevator.passengersOnboard == 0)
                [wAvatar setColor:ccc3(118,118,118)];
            else
                [wAvatar setColor:ccc3(255, 255, 255)];
			wAvatar.visible = wElevator.visible;
			if(wElevator.visible)
			{
				wAvatar.position = ccp(mShaft1X, (wElevator.floor - mFloorMin) * wPixPerFloor);	
			}
		}

		// Handle shaft2 elevators
		for(UInt8 i = 0; i < MAX_ELS_IN_SHAFT; i++)
		{
			wAvatar = [mShaft2Sprites objectAtIndex:i];
			wElevator = [mShaft2 objectAtIndex:i];
			if(wElevator.visible && wElevator.passengersOnboard == 0)
                [wAvatar setColor:ccc3(118,118,118)];
            else
                [wAvatar setColor:ccc3(255, 255, 255)];
			wAvatar.visible = wElevator.visible;
			if(wElevator.visible)
			{
				wAvatar.position = ccp(mShaft2X, (wElevator.floor - mFloorMin) * wPixPerFloor);	
			}
		}
		
		// Handle shaft3 elevators
		for(UInt8 i = 0; i < MAX_ELS_IN_SHAFT; i++)
		{
			wAvatar = [mShaft3Sprites objectAtIndex:i];
			wElevator = [mShaft3 objectAtIndex:i];
            if(wElevator.visible && wElevator.passengersOnboard == 0)
                [wAvatar setColor:ccc3(118,118,118)];
            else
                [wAvatar setColor:ccc3(255, 255, 255)];
			wAvatar.visible = wElevator.visible;
			if(wElevator.visible)
			{
				wAvatar.position = ccp(mShaft3X, (wElevator.floor - mFloorMin) * wPixPerFloor);	
			}
		}
		
		// Handle shaft4 elevators
		for(UInt8 i = 0; i < MAX_ELS_IN_SHAFT; i++)
		{
			wAvatar = [mShaft4Sprites objectAtIndex:i];
			wElevator = [mShaft4 objectAtIndex:i];
            if(wElevator.visible && wElevator.passengersOnboard == 0)
                [wAvatar setColor:ccc3(118,118,118)];
            else
                [wAvatar setColor:ccc3(255, 255, 255)];
			wAvatar.visible = wElevator.visible;
			if(wElevator.visible)
			{
				wAvatar.position = ccp(mShaft4X, (wElevator.floor - mFloorMin) * wPixPerFloor);	
			}
		}
		
		// And finally, the CEO's elevator
		wAvatar = [mShaft4Sprites objectAtIndex:MAX_ELS_IN_SHAFT];
		wAvatar.visible = mCeoEl.visible;
		if(mCeoEl.visible && mCeoEl.floor < mCeoEl.floorMax)
		{
			wAvatar.position = ccp(mShaft4X, (mCeoEl.floor - mFloorMin) * wPixPerFloor);
		}
        else if(mCeoEl.floor >= mOwnEl.floorMax && mCeoEl.visible)
        {
            wAvatar.visible = NO;
        }
        
        // And finally, finally the CEO's preview elevator
		wAvatar = [mShaft4Sprites objectAtIndex:MAX_ELS_IN_SHAFT+1];
		//wAvatar.visible = (!mCeoEl.reachedFloor && mCeoEl.activeInGame && (mCeoEl.stopsRemaining > 0));
        if(mCeoEl.shaft.gettingReadyForCEO)
        {
            wAvatar.visible = YES;
        }
		//if(mCeoEl.floor < mCeoEl.floorMax)
            //{
			wAvatar.position = ccp(mShaft4X, (mCeoEl.floorGoingToPreview - mFloorMin) * wPixPerFloor);
		//}
        //else if(mCeoEl.floor >= mOwnEl.floorMax && mCeoEl.visible)
        //{
        //    wAvatar.visible = NO;
        //}
	}
}

@synthesize clippingSize = mClippingSize;

-(void) setShaftElevatorsOn: (UInt8) floor with:(CCArray*)array
{
	switch (floor)
	{
		case 1:
			mShaft1 = [array retain];
			mElevatorCountValid++;
			break;
		case 2:
			mShaft2 = [array retain];
			mElevatorCountValid++;
			break;
		case 3:
			mShaft3 = [array retain];
			mElevatorCountValid++;
			break;
		case 4:
			mShaft4 = [array retain];
			mElevatorCountValid++;
			break;
		default:
			break;
	}
}

-(void) setOwnElevator:(OwnGameElevator*)own ceoElevator:(CeoElevator*)ceo;
{
	mOwnEl = [own retain];
	mCeoEl = [ceo retain];
	mElevatorCountValid++;
}

-(void) setFloorMinimum:(UInt16)min maximum:(UInt16)max
{
	mFloorMin = min;
	mFloorMax = max;
}

-(void) hideRadarForFloors:(UInt16)total
{
    // Play the radar loss sound effect
    [[AudioController sharedInstance] playSound:kNoRadarBonus];
    
	// Reset the values
	mLastOwnElevatorFloor = 0;
	mNumberOfFloorsToHide = total;
	mNumberOfFloorsToHideTotal = total;
	[mFloorsRemainLabel setString:[NSString stringWithFormat:@"%i", mNumberOfFloorsToHide]];

	[mAllRadarSprites runAction:[CCSequence actions:
								 [CCBlink actionWithDuration:RADAR_INDICATOR_BLINK_TIME blinks:NUM_BLINKS_RADAR_HIDDEN],
								 [CCHide action],
								 [CCCallFuncO actionWithTarget:mRadarCountdownSprites selector:@selector(runAction:) object:[CCShow action]],
								 [CCCallFunc actionWithTarget:self selector:@selector(flashLockAndNumber)],
								 nil]];
}

-(void) showRadar
{
    // Play the radar recover sound effect
    [[AudioController sharedInstance] playSound:kRecoverRadar];
    
	[mAllRadarSprites runAction:[CCSequence actions:
								 [CCCallFuncO actionWithTarget:mRadarCountdownSprites selector:@selector(runAction:) object:[CCHide action]],
								 [CCBlink actionWithDuration:RADAR_INDICATOR_BLINK_TIME blinks:NUM_BLINKS_RADAR_HIDDEN],
								 [CCShow action],
								 nil]];
}

-(void) flashLockAndNumber
{
	CCDelayTime* wDelay = [CCDelayTime actionWithDuration:RADAR_LOCK_DISPLAY_SEC];
	CCCallFuncO* wCallFade = [CCCallFuncO actionWithTarget:mLockSprite selector:@selector(runAction:) object:[CCFadeOut actionWithDuration:RADAR_LOCK_DISPLAY_SEC]];
	CCCallFuncO* wCallShow = [CCCallFuncO actionWithTarget:mFloorsRemainLabel selector:@selector(runAction:) object:[CCShow action]];
	
	CCSequence* wSequence = [CCSequence actions:
						   wCallFade,
						   wDelay,
						   wCallShow,
						   nil];
	
	[self runAction:wSequence];	
}

-(void) rotateLockCircle
{
	CCSprite* wSprite;
	
	float wDelay = 0.0f;
	
	CCARRAY_FOREACH(mCircleSprites, wSprite)
	{
		[wSprite runAction:
		 [CCSequence actions:
		  [CCDelayTime actionWithDuration:wDelay],
		  [CCFadeOut actionWithDuration:0.07f],
		  [CCFadeIn actionWithDuration:0.07f],
		  nil]];
		wDelay += 0.07f;
	}
}

+(ccColor3B) colorFromRedToGreen:(float)percent
{
	// 512 degrees of variation (R = 256, G = 256)
	GLubyte wRed, wGreen, wBlue = 0;
	
	// Begin with Red 255, Green, Blue 0
	// During transition the Green should increase to 255, when reached the Red should decrease to 0
	UInt16 wTotal = (UInt16)roundf(percent * 512);
	
	if(wTotal <= 255)
	{
		wRed = 255;
		wGreen = wTotal;
	}
	else
	{
		wRed = 255 - (wTotal - 255);
		wGreen = 255;
	}
	
	ccColor3B wColor;
	wColor.r = wRed;
	wColor.g = wGreen;
	wColor.b = wBlue;
	
	return wColor;
}

@end
