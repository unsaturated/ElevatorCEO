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

#import "GameStatus.h"

@implementation GameStatus

-(id) init
{
	if( (self = [super init]) )
	{
		// Establish properties of control layer itself
		[self setAnchorPoint:CGPointZero];
		
        if([GameController sharedInstance].is16x9)
        {
            // iPhone 5 uses a common radar/score background sprite
            mBackground = [CCSprite spriteWithSpriteFrameName:@"radar-score-bg.png"];
            [mBackground setAnchorPoint:CGPointZero];
            [self addChild:mBackground z:0];
        }
        else
        {
            mBackground = [CCSprite spriteWithSpriteFrameName:@"score-bg.png"];
            [mBackground setAnchorPoint:CGPointZero];
            [self addChild:mBackground z:0];
        }
		
		// Synergy or health status bar
		mSynergy = [GameSynergy node];
        if([GameController sharedInstance].is16x9)
            mSynergy.position = ccp(12, 86 );
        else
            mSynergy.position = ccp(12, 75);
		
		[self addChild:mSynergy z:5];
		
		// Life indicators
		CGPoint wLifePos = CGPointZero;
        if([GameController sharedInstance].is16x9)
            wLifePos = ccp(22, 130);
        else
            wLifePos = ccp(22, 110);
		mLifeSprites = [[CCArray array] retain];
		for (UInt8 i = 0; i < NUM_LIFE_INDICATORS; i++) 
		{
			CCSprite *wSprite = [CCSprite spriteWithSpriteFrameName:@"heart.png"];
			wSprite.visible = NO;
            if([GameController sharedInstance].is16x9)
                [wSprite setScale:0.80f];
            else
                [wSprite setScale:0.70f];
			[mLifeSprites addObject: wSprite];
			[self addChild: [mLifeSprites lastObject] z:5];
			wSprite.position = wLifePos;
			wLifePos = ccpAdd(wLifePos, ccp(20,0));
		}
		
		mLives = 0;
		
		// Localize the pension amount
		mFormatter = [[[NSNumberFormatter alloc] init] retain];
		[mFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[mFormatter setMaximumFractionDigits:0];
		
		// Labels
        mLabel1 = [CCLabelBMFont labelWithString:NSLocalizedString(@"SYNERGY_LABEL", nil) fntFile:[GameController selectFont:kDroidSansBold13White]];

        if([GameController sharedInstance].is16x9)
        {
            if(![GameController isChineseLang])
                mLabel1.position = ccp(42, 104);
            else
                mLabel1.position = ccp(42, 106);
        }
        else
        {
            if(![GameController isChineseLang])
                mLabel1.position = ccp(42, 90);
            else
                mLabel1.position = ccp(42, 91);
        }
		[self addChild:mLabel1];
		
        mLabel2 = [CCLabelBMFont labelWithString:NSLocalizedString(@"PENSION_LABEL", nil) fntFile:[GameController selectFont:kDroidSansBold13White]];

        if([GameController sharedInstance].is16x9)
            mLabel2.position = ccp(42, 68);
        else
            mLabel2.position = ccp(42, 60);
		[self addChild:mLabel2];
		
		NSString *wPension = [mFormatter stringFromNumber:[NSNumber numberWithFloat:0.0f]];
        NSString *wPensionFormatted = [GameController convertToAscii:wPension];
        mLabelPension = [CCLabelBMFont labelWithString:wPensionFormatted fntFile:[GameController selectFont:kDroidSans11White]];
        if([GameController sharedInstance].is16x9)
            mLabelPension.position = ccp(42, 54);
        else
            mLabelPension.position = ccp(42, 48);
		[self addChild:mLabelPension];
		
        mLabel3 = [CCLabelBMFont labelWithString:NSLocalizedString(@"LEVEL_LABEL", nil) fntFile:[GameController selectFont:kDroidSansBold13White]];
        if([GameController sharedInstance].is16x9)
            mLabel3.position = ccp(42, 32);
        else
            mLabel3.position = ccp(42, 30);
		[self addChild:mLabel3];
		
        mLabelLevel = [CCLabelBMFont labelWithString:@"0" fntFile:[GameController selectFont:kDroidSans11White]];
        if([GameController sharedInstance].is16x9)
            mLabelLevel.position = ccp(42, 18);
        else
            mLabelLevel.position = ccp(42, 17);
		[self addChild:mLabelLevel];
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

- (void) dealloc
{
    [mLifeSprites release];
	[mFormatter release];
	CCLOG(@"---DEALLOC %@", self);
	[super dealloc];
}

- (void) onExit
{
	[super onExit];
}

-(float) synergyLevel
{
	return [mSynergy synergyLevel];
}

-(void) setSynergyLevel:(float)value
{
	[mSynergy setSynergy: value];
}

-(UInt8) lives
{
	return mLives;
}

-(void) setLives:(UInt8)value
{
	// Don't bother updating if nothing changed
	if( (value == mLives) || (value > NUM_LIFE_INDICATORS) )
		return;
	
	BOOL wIncreased = (value > mLives);

	CCSprite *wLife;
	
	if(wIncreased)
	{
		// Display new life indicators
		for(char i = mLives; i <= value - 1; i++)
		{
			wLife = [mLifeSprites objectAtIndex:i];
			[wLife runAction:[CCSequence actionOne:[CCShow action] 
											   two:[CCFadeIn actionWithDuration:LIFE_INDICATOR_BLINK_TIME]]];				
		}
	}
	else 
	{
		// Hide existing life indicators
		for(UInt8 i = mLives - 1; (i >= value && i >= 0); i--)
		{
			wLife = [mLifeSprites objectAtIndex:i];
			[wLife runAction:[CCSequence actionOne:[CCBlink actionWithDuration:LIFE_INDICATOR_BLINK_TIME blinks:NUM_BLINKS_LIFE_DECREASE]
											   two:[CCHide action]]];
            
            // Catch overflow conditions
            if( (i <= 0) || (i > NUM_LIFE_INDICATORS) )
                break;
		}
	}
    
    CCLOG(@"Setting lives = %d", value);

	mLives = value;
}

-(UInt16) level
{
	return mLevel;
}

-(void) setLevel:(UInt16)value
{
	if(value != mLevel)
	{
		mLevel = value;
        NSString* formatted = [mFormatter stringFromNumber:[NSNumber numberWithInt:mLevel]];
		[mLabelLevel setString:[GameController convertToAscii:formatted]];
	}
	
}

@synthesize pension = mPension;

-(void) setPension:(float)value
{
	float wLastPension = mPension;
	mPension = clampf(value, GAME_MIN_PENSION, GAME_MAX_PENSION);

	if(mPension > wLastPension)
		[mLabelPension runAction:[CCSequence actionOne:[CCTintTo actionWithDuration:0.4f red:0 green:255 blue:0] two:[CCTintTo actionWithDuration:0.4f red:255 green:255 blue:255]]];
	else if(mPension < wLastPension)
		[mLabelPension runAction:[CCSequence actionOne:[CCTintTo actionWithDuration:0.4f red:255 green:0 blue:0] two:[CCTintTo actionWithDuration:0.4f red:255 green:255 blue:255]]];

    NSString* formattedPension = [mFormatter stringFromNumber:[NSNumber numberWithFloat:mPension]];
	[mLabelPension setString:[GameController convertToAscii:formattedPension]];
}

-(void) changePensionBy:(float)amount
{
	[self setPension:(amount + self.pension)];
}

-(void) changeSynergyBy:(float)amount
{
    [self setSynergyLevel:(amount + self.synergyLevel)];
}

@end
