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

#import "GameLevelTransition.h"

@implementation GameLevelTransition

+(id) transitionWithLevel:(UInt8)level floorMin:(UInt16)min floorMax:(UInt16)max
{
	return [[[self alloc] initWithLevel:level floorMin:min floorMax:max] autorelease];
}

-(id) init
{
	if( (self = [super init]) )
	{
        CGRect winRect = [[GameController sharedInstance] gamingAreaRectForPlay:YES];
		CGSize winSize = winRect.size;
        
        // Set this to extra high priority since most other objects are at priority 0
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
        
		// Set the size to be the 
		[self setContentSize:CGSizeMake(240.0f, winSize.height)];
		[self setAnchorPoint:CGPointMake(0.0f, 0.0f)];
		
		// Localize the floor numbers
		mFormatter = [[[NSNumberFormatter alloc] init] retain];
		[mFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[mFormatter setMaximumFractionDigits:0];
        
        CCLayer* wTextContainer = [CCLayer node];
        [wTextContainer setContentSize:CGSizeMake(240.0f, winSize.height)];
        [self addChild:wTextContainer z:2];
        wTextContainer.rotation = 30.0f;
        wTextContainer.position = ccp(-5, 30);
		
		CCSprite* wBg = [CCSprite spriteWithSpriteFrameName:@"transition.png"];
		[wBg setAnchorPoint:CGPointZero];
		wBg.position = CGPointZero;
		[self addChild:wBg z:1];
		
		// Level
		//   N
		CCLabelBMFont* wLevel = [CCLabelBMFont labelWithString:NSLocalizedString(@"LEVEL_LABEL", nil) fntFile:[GameController selectFont:kLeague72White]];
		wLevel.position = ccp(self.contentSize.width / 2.0f, 310.0f);
		[wTextContainer addChild:wLevel z:2];
		
		mLevelLabel = [CCLabelBMFont labelWithString:@"0" fntFile:[GameController selectFont:kLeague72White forceDefault:YES]];
		mLevelLabel.position = ccp(self.contentSize.width / 2.0f, (![GameController isChineseLang]) ? 250.0f : 235.0f);
		[wTextContainer addChild:mLevelLabel z:2];
		
		
		// Floors
		//  X-Y
		CCLabelBMFont* wFloors = [CCLabelBMFont labelWithString:NSLocalizedString(@"FLOORS_LABEL", nil) fntFile:[GameController selectFont:kLeague24White]];
		wFloors.position = ccp(self.contentSize.width / 2.0f, 170.0f);
		[wTextContainer addChild:wFloors z:2];
		
		mFloorsLabel = [CCLabelBMFont labelWithString:@"1 - 100" fntFile:[GameController selectFont:kLeague24White forceDefault:YES]];
		mFloorsLabel.position = ccp(self.contentSize.width / 2.0f, 145.0f);
		[wTextContainer addChild:mFloorsLabel z:2];
				   
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

-(id) initWithLevel:(UInt8)level floorMin:(UInt16)min floorMax:(UInt16)max
{
	if( (self = [self init]) )
	{
        mLevel = level;
        
		// Gets the locale for the floor numbers
		NSString *wMin = [mFormatter stringFromNumber:[NSNumber numberWithInt:min]];
		NSString *wMax = [mFormatter stringFromNumber:[NSNumber numberWithInt:max]];
        
        NSString *wMinFormatted = [GameController convertToAscii:wMin];
        NSString *wMaxFormatted = [GameController convertToAscii:wMax];
		
		[mLevelLabel setString:[NSString stringWithFormat:@"%d", level]];
		[mFloorsLabel setString:[NSString stringWithFormat:@"%@ - %@", wMinFormatted, wMaxFormatted]];
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
	[mFormatter release];
	[super dealloc];
}

-(void) showTransition
{
    CGRect winRect = [[GameController sharedInstance] gamingAreaRectForPlay:YES];
    CGSize winSize = winRect.size;
    
	CCSequence* wAction = [CCSequence actions:
						   [CCShow action],
						   [CCDelayTime actionWithDuration:(TRANSITION_LAYER_DISPLAY_SEC / 2.0f)],
                           [CCCallFunc actionWithTarget:self selector:@selector(displayInterstitialAd)],
                           [CCDelayTime actionWithDuration:(TRANSITION_LAYER_DISPLAY_SEC / 2.0f)],
                           [CCCallFunc actionWithTarget:[AudioController sharedInstance] selector:@selector(playNewLevelTransition)],
						   [CCMoveTo actionWithDuration:AC_NEW_LEVEL_DURATION position:ccp(self.position.x,winSize.height)],
						   [CCCallFunc actionWithTarget:self selector:@selector(transitionCleanup)],
						   nil];
	
	[self runAction:wAction];
}

-(void) transitionCleanup
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[self removeFromParentAndCleanup:YES];
}

-(void) displayInterstitialAd
{
    // Show the ad if correct device
    if(![GameController sharedInstance].adsRemovedByUser && [GameController sharedInstance].is16x9Device && (mLevel > 1) && (mLevel % 3 == 0))
    {
        BOOL wDisplayInterstitial = [[GameController sharedInstance].rootViewController requestInterstitialAdPresentation];
        CCLOG(@"iAd: Display interstitial (%d) for level %d", wDisplayInterstitial, mLevel);
        if(wDisplayInterstitial)
        {
            [[GameController sharedInstance] pause:YES];
        }
    }
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
    
    if(CGRectContainsPoint(self.boundingBox, convertedLocation))
    {
        return YES;
    }
    
    return NO;
}

@end
