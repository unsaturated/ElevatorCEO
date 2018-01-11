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

#import "BaseTutorialTip.h"
#import "GameController.h"
#import "GamePlayLayer.h"

@implementation BaseTutorialTip

+(id) lastTip:(BOOL)tutorialViewed
{
    return [[[self alloc] initWithTutorialViewed] autorelease];
}

-(id) init
{
	if( (self = [super init]) )
	{
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
		// Set the size to be the 
		[self setContentSize:CGSizeMake(236, 91)];
		[self setAnchorPoint:CGPointZero];
		
		CCSprite* wBg = [CCSprite spriteWithSpriteFrameName:@"tutorial-bg.png"];
		[wBg setAnchorPoint:CGPointZero];
		wBg.position = ccp(0, 0);
		[self addChild:wBg z:1];
		
        mLine1 = [CCLabelBMFont labelWithString:NSLocalizedString(@"", nil) fntFile:[GameController selectFont:kDroidSansBold11Black]];
        [mLine1 setAnchorPoint:CGPointZero];
		mLine1.position = ccp(44, 69);
		[self addChild:mLine1 z:10];
        
        mLine2 = [CCLabelBMFont labelWithString:NSLocalizedString(@"", nil) fntFile:[GameController selectFont:kDroidSansBold11Black]];
		[mLine2 setAnchorPoint:CGPointZero];
        mLine2.position = ccp(44, 52);
		[self addChild:mLine2 z:10];
        
        mLine3 = [CCLabelBMFont labelWithString:NSLocalizedString(@"", nil) fntFile:[GameController selectFont:kDroidSansBold11Black]];
		[mLine3 setAnchorPoint:CGPointZero];
        mLine3.position = ccp(44, 35);
		[self addChild:mLine3 z:10];
        
        mLine4 = [CCLabelBMFont labelWithString:NSLocalizedString(@"", nil) fntFile:[GameController selectFont:kDroidSansBold11Black]];
		[mLine4 setAnchorPoint:CGPointZero];
        mLine4.position = ccp(44, 18);
		[self addChild:mLine4 z:10];
        
        tutorialViewed = NO;
        
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

-(id) initWithTutorialViewed
{
    if( self = [self init])
    {
        self.tutorialViewed = YES;
    }
    
    return self;
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
	[super dealloc];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{    
    CCDirector* sd = [CCDirector sharedDirector];
    
    // First convert from UITouch location
    CGPoint tempLoc = [touch locationInView: [touch view]];
    // Then convert to GL location
	CGPoint touchLocation = [sd convertToGL:tempLoc];
    // Finally convert from the GL touch location to the actual node space
    CGPoint nodeLoc = [self convertToNodeSpace:touchLocation];
    // Create a rectangle at 0,0 with actual node width and height
    CGRect thisRect = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    
    if(CGRectContainsPoint(thisRect, nodeLoc))
    {
        [self exitTip:NO];
        
        return YES;
    }
    
    return NO;
}

-(void) showTip
{
    CGSize winSize = [[GameController sharedInstance] gamingAreaRectForPlay:YES].size;
    
	CCSequence* wAction = [CCSequence actions:
						   [CCShow action],
                           [CCMoveTo actionWithDuration:TUTORIAL_ANIMATION_SEC position:ccp(self.position.x, winSize.height)],
						   nil];
	
	[self runAction:wAction];
}

-(GamePlayLayer*) gamePlayLayer
{
    return (GamePlayLayer*)[self parent];
}

-(void) showNextTip
{
    // Override in base classes
}

-(void) exitTip:(BOOL)immediate
{
    if(!immediate)
    {
        CGSize winSize = [[GameController sharedInstance] gamingAreaRectForPlay:YES].size;
        
        CCSequence* wAction = [CCSequence actions:
                               [CCMoveTo actionWithDuration:TUTORIAL_ANIMATION_SEC position:ccp(self.position.x,winSize.height + self.contentSize.height)],
                               [CCCallFunc actionWithTarget:self selector:@selector(showNextTip)],
                               [CCCallFunc actionWithTarget:self selector:@selector(transitionCleanup)],
                               nil];
        
        // Animate out of view
        [self runAction:wAction];
        
        // If it's the last tip, then inform the GameController
        if(self.tutorialViewed)
            [GameController sharedInstance].tutorialViewed = YES;
        
        // Remove the touch delegate
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    }
    else 
    {
        self.visible = NO;
        
        // If it's the last tip, then inform the GameController
        if(self.tutorialViewed)
            [GameController sharedInstance].tutorialViewed = YES;
        
        // Remove the touch delegate
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
        
        [self transitionCleanup];
    }
}

-(void) transitionCleanup
{
	[self removeFromParentAndCleanup:YES];
}

@synthesize tutorialViewed;

@end
